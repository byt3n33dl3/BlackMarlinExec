/*
 * server_table.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/asn1.h>

#include <common_table.h>
#include <charbuf.h>
#include <pelz_enclave_log.h>

#include "sgx_trts.h"
#include ENCLAVE_HEADER_TRUSTED
#include "kmyth_enclave_trusted.h"
#include "ec_key_cert_unmarshal.h"
#include "server_table.h"

pelz_identity_t pelz_id = {.private_pkey = NULL,
			   .cert         = NULL,
			   .common_name  = NULL};

static charbuf get_common_name_from_cert(X509* cert);

TableResponseStatus add_cert_to_table(TableType type, uint64_t handle)
{
  Entry tmp_entry;
  uint8_t * data = NULL;
  size_t data_size = 0;
  int ret;
  size_t index = 0;
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  if (table->mem_size >= MAX_MEM_SIZE)
  {
    pelz_sgx_log(LOG_ERR, "Server Table memory allocation greater then specified limit.");
    return MEM_ALLOC_FAIL;
  }

  data_size = retrieve_from_unseal_table(handle, &data);
  if (data_size == 0)
  {
    pelz_sgx_log(LOG_ERR, "Failure to retrieve data from unseal table.");
    return RET_FAIL;
  }

  ret = unmarshal_ec_der_to_x509(data, data_size, &tmp_entry.value.cert);
  if (ret)
  {
    pelz_sgx_log(LOG_ERR, "Unmarshal DER to X509 Failure");
    free(data);
    return ERR_X509;
  }
  free(data);
  tmp_entry.id = get_common_name_from_cert(tmp_entry.value.cert);
  if(tmp_entry.id.chars == NULL || tmp_entry.id.len == 0)
  {
    pelz_sgx_log(LOG_ERR, "Failed to extract common name from certificate.");
    free_charbuf(&tmp_entry.id);
    X509_free(tmp_entry.value.cert);
    return ERR_X509;
  }
  
  if (table_lookup(type, tmp_entry.id, &index) == 0)
  {
    if (X509_cmp(table->entries[index].value.cert, tmp_entry.value.cert) == 0)
    {
      pelz_sgx_log(LOG_DEBUG, "Cert already added.");
      free_charbuf(&tmp_entry.id);
      X509_free(tmp_entry.value.cert);
      return OK;
    }
    else
    {
      pelz_sgx_log(LOG_ERR, "Cert entry and Server ID lookup do not match.");
      free_charbuf(&tmp_entry.id);
      X509_free(tmp_entry.value.cert);
      return NO_MATCH;
    }
  }

  Entry *temp;

  if ((temp = (Entry *) realloc(table->entries, (table->num_entries + 1) * sizeof(Entry))) == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Cert List Space Reallocation Error");
    free_charbuf(&tmp_entry.id);
    X509_free(tmp_entry.value.cert);
    return ERR_REALLOC;
  }
  else
  {
    table->entries = temp;
  }
  table->entries[table->num_entries] = tmp_entry;
  table->num_entries++;
  table->mem_size = table->mem_size + (tmp_entry.id.len * sizeof(char)) + sizeof(size_t) + data_size;
  pelz_sgx_log(LOG_INFO, "Cert Added");
  return OK;
}

TableResponseStatus private_pkey_init(void)
{
  pelz_id.private_pkey = EVP_PKEY_new();
  if (pelz_id.private_pkey == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Error allocating EVP_PKEY");
    return MEM_ALLOC_FAIL;
  }
  return OK;
}

TableResponseStatus private_pkey_free(void)
{
  EVP_PKEY_free(pelz_id.private_pkey);
  X509_free(pelz_id.cert);
  free(pelz_id.common_name);
  pelz_id.private_pkey = NULL;
  pelz_id.cert        = NULL;
  pelz_id.common_name = NULL;
  return OK;
}

TableResponseStatus private_pkey_add(uint64_t pkey_handle, uint64_t cert_handle)
{
  uint8_t *data;
  size_t data_size = 0;
  data_size = retrieve_from_unseal_table(pkey_handle, &data);
  if (data_size == 0)
  {
    pelz_sgx_log(LOG_ERR, "Failure to retrieve data from unseal table.");
    return RET_FAIL;
  }
  if (unmarshal_ec_der_to_pkey(data, data_size, &(pelz_id.private_pkey)) != EXIT_SUCCESS)
  {
    pelz_sgx_log(LOG_ERR, "Failure to unmarshal ec_der to pkey");
    free(data);
    return ERR_X509;
  }

  data_size = 0;
  data_size = retrieve_from_unseal_table(cert_handle, &data);
  if(data_size == 0)
  {
    pelz_sgx_log(LOG_ERR, "Failed to retrieve pelz cert from unseal table.");
    return RET_FAIL;
  }
  if(unmarshal_ec_der_to_x509(data, data_size, &(pelz_id.cert)))
  {
    free(data);
    pelz_sgx_log(LOG_ERR, "Failed to parse pelz cert.");
    return ERR_X509;
  }
  free(data);

  if(X509_check_private_key(pelz_id.cert, pelz_id.private_pkey) != 1)
  {
    pelz_sgx_log(LOG_ERR, "Certificate/private key mismatch.");
    private_pkey_free();
    return ERR_X509;
  }
  charbuf common_name = get_common_name_from_cert(pelz_id.cert);
  if(common_name.chars == NULL || common_name.len == 0)
  {
    pelz_sgx_log(LOG_ERR, "Failed to extract pelz common name from certificate.");
    private_pkey_free();
    return RET_FAIL;
  }
  
  pelz_id.common_name = calloc(common_name.len+1, sizeof(char));
  pelz_id.common_name = memcpy(pelz_id.common_name, common_name.chars, common_name.len);
  free_charbuf(&common_name);
  return OK;
}

static charbuf get_common_name_from_cert(X509* cert)
{
  if(cert == NULL)
  {
    return new_charbuf(0);
  }
  X509_NAME *subj = X509_get_subject_name(cert);
  if(subj == NULL)
  {
    return new_charbuf(0);
  }

  int lastpos = -1;
  int len;
  const unsigned char* tmp_id;

  // We want the last NID_commonName entry in the certificate in accordance
  // with RFC 6125.
  for(;;)
  {
    int count = X509_NAME_get_index_by_NID(subj, NID_commonName, lastpos);
    if(count == -1)
    {
      break;
    }
    lastpos = count;
  }

  X509_NAME_ENTRY* entry = X509_NAME_get_entry(subj, lastpos);
  ASN1_STRING *entry_data = X509_NAME_ENTRY_get_data(entry);

  len = ASN1_STRING_length(entry_data);
  if(len <= 0)
  {
    pelz_sgx_log(LOG_ERR, "Failed to parse X509 string.")
      return new_charbuf(0);
  }
  
  tmp_id = ASN1_STRING_get0_data(entry_data);
  charbuf common_name = new_charbuf((size_t)len);
  if((size_t)len != common_name.len)
  {
    pelz_sgx_log(LOG_ERR, "Charbuf creation error.");
    free_charbuf(&common_name);
    return new_charbuf(0);
  }
  memcpy(common_name.chars, tmp_id, common_name.len);
  return common_name;  
}
