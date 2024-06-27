#include <stdlib.h>
#include <stdio.h>
#include <kmyth/file_io.h>
#include <kmyth/memory_util.h>
#include <kmyth/kmyth_seal_unseal_impl.h>

#include "pelz_log.h"
#include "pelz_loaders.h"
#include "pelz_request_handler.h"

#include "sgx_urts.h"
#include "sgx_seal_unseal_impl.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

int pelz_load_key_from_file(char *filename, charbuf * key)
{
  size_t key_len;

  unsigned char tmp_key[MAX_KEY_LEN];
  FILE *key_file_handle = NULL;

  key_file_handle = fopen(filename, "r");
  if (key_file_handle == NULL)
  {
    pelz_log(LOG_ERR, "Failed to open key file %s", filename);
    return 1;
  }

  key_len = fread(tmp_key, sizeof(char), MAX_KEY_LEN, key_file_handle);

  // If we've not reached EOF something has probably gone wrong.
  if ((key_len == 0) || (!feof(key_file_handle)))
  {
    pelz_log(LOG_ERR, "Error: Failed to fully read key file.");
    secure_memset(tmp_key, 0, key_len);
    fclose(key_file_handle);
    return 1;
  }
  fclose(key_file_handle);

  *key = new_charbuf(key_len);
  if (key->len == 0)
  {
    pelz_log(LOG_ERR, "Error: Failed to allocate memory for key.");
    return 1;
  }
  memcpy(key->chars, tmp_key, key->len);
  secure_memset(tmp_key, 0, key_len);
  return 0;
}

int pelz_load_file_to_enclave(char *filename, uint64_t * handle)
{
  int ext;
  uint8_t *data = NULL;
  size_t data_len = 0;
  uint8_t *data_out = NULL;
  size_t data_out_len = 0;

  if (read_bytes_from_file(filename, &data, &data_len))
  {
    pelz_log(LOG_ERR, "Unable to read file %s ... exiting", filename);
    return (1);
  }
  pelz_log(LOG_DEBUG, "Read %d bytes from file %s", data_len, filename);

  ext = get_file_ext(filename);
  switch (ext)
  {
  case SKI:
    if(pelz_unseal_ski(data, data_len, &data_out, &data_out_len))
    {
      pelz_log(LOG_ERR, "Failed to tpm-unseal %s ... exiting", filename);
      free(data);
      return (1);
    }
    free(data);
    if( pelz_unseal_nkl(data_out, data_out_len, handle))
    {
      pelz_log(LOG_ERR, "Failed to sgx-unseal %s ... exiting", filename);
      free(data_out);
      return (1);
    }
    free(data_out);
    break;
  case NKL:
    if(pelz_unseal_nkl(data, data_len, handle))
    {
      pelz_log(LOG_ERR, "Failed to sgx-unseal %s ... exiting", filename);
      free(data);
      return (1);
    }
    free(data);
    break;
  default:
    free(data);
    pelz_log(LOG_ERR, "Invalid file type of file %s ... exiting", filename);
    return (1);
  }
  return (0);
}

int pelz_unseal_ski(uint8_t * data, size_t data_len, uint8_t ** data_out, size_t * data_out_len)
{
  if (tpm2_kmyth_unseal(data, data_len, data_out, data_out_len, NULL, 0, NULL, 0, false))
  {
    pelz_log(LOG_ERR, "TPM unseal failed");
    return (1);
  }

  return (0);
}

int pelz_unseal_nkl(uint8_t * data, size_t data_len, uint64_t * handle)
{
  if (kmyth_sgx_unseal_nkl(eid, data, data_len, handle))
  {
    pelz_log(LOG_ERR, "Unable to unseal contents ... exiting");
    return (1);
  }
  pelz_log(LOG_DEBUG, "SGX unsealed nkl file with %lu handle", handle);
  return (0);
}
