/*
 * ca_table.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <openssl/x509.h>
#include <openssl/x509_vfy.h>
#include <openssl/x509v3.h>

#include <common_table.h>
#include <charbuf.h>
#include <pelz_enclave_log.h>

#include "ca_table.h"
#include "sgx_trts.h"
#include ENCLAVE_HEADER_TRUSTED
#include "kmyth_enclave_trusted.h"


int validate_cert(X509* cert)
{
  bool result = 1;
  Table* table = get_table_by_type(CA_TABLE);
  if(table == NULL)
  {
    return result;
  }

  X509_STORE* store = X509_STORE_new();
  if(store == NULL)
  {
    return result;
  }

  for(size_t i = 0; i < table->num_entries; i++)
  {
    if(X509_STORE_add_cert(store, (X509*)(table->entries[i].value.cert)) != 1)
    {
      return result;
    }
  }

  X509_STORE_CTX* store_ctx = X509_STORE_CTX_new();
  if(store_ctx == NULL)
  {
    X509_STORE_free(store);
    return result;
  }
  
  if(X509_STORE_CTX_init(store_ctx, store, cert, NULL) != 1)
  {
    X509_STORE_CTX_free(store_ctx);
    X509_STORE_free(store);
    return result;
  }

  if(X509_verify_cert(store_ctx) == 1){
    result = 0;
  }
  X509_STORE_CTX_free(store_ctx);
  X509_STORE_free(store);
  return result;
}

