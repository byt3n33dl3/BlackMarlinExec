/*
 * file_seal_encrypt_decrypt.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <libgen.h>
#include <sys/stat.h>
#include <kmyth/file_io.h>
#include <kmyth/kmyth_seal_unseal_impl.h>

#include "pelz_log.h"
#include "file_seal_encrypt_decrypt.h"

#include "pelz_enclave.h"
#include "sgx_seal_unseal_impl.h"
#include "pelz_request_handler.h"

#define ENCLAVE_PATH "sgx/pelz_enclave.signed.so"

int seal(char *filename, char **outpath, size_t outpath_size, bool tpm)
{
  uint8_t *data = NULL;
  size_t data_len = 0;
  uint8_t *sgx_seal = NULL;
  size_t sgx_seal_len = 0;
  uint8_t *tpm_seal = NULL;
  size_t tpm_seal_len = 0;

  pelz_log(LOG_DEBUG, "Seal function");
  //Validating filename and data from file
  if (read_validate(filename, &data, &data_len))
  {
    return 1;          
  }

  //SGX sealing of data in nkl format
  if (seal_nkl(data, data_len, &sgx_seal, &sgx_seal_len))
  {
    free(data);
    return 1;    
  }
  free(data);

  //Checking if TPM seal is requested
  if (tpm)
  {
    //TPM sealing of data in ski format
    if (seal_ski(sgx_seal, sgx_seal_len, &tpm_seal, &tpm_seal_len))
    {
      free(sgx_seal);
      return 1;
    }
    free(sgx_seal);
  }

  //Checking and/or setting output path
  if (outpath_validate(filename, outpath, outpath_size, tpm))
  {
    return 1;
  }

  //Write bytes to file based on outpath
  if (tpm)
  {
    if (write_bytes_to_file(*outpath, tpm_seal, tpm_seal_len))
    {
      pelz_log(LOG_ERR, "error writing data to .ski file ... exiting");
      free(tpm_seal);
      return 1;
    }
    free(tpm_seal);
  }
  else
  {
    if (write_bytes_to_file(*outpath, sgx_seal, sgx_seal_len))
    {
      pelz_log(LOG_ERR, "error writing data to .nkl file ... exiting");
      free(sgx_seal);
      return 1;
    }
    free(sgx_seal);
  }
  return 0;
}

int seal_ski(uint8_t * data, size_t data_len, uint8_t ** data_out, size_t * data_out_len)
{
  pelz_log(LOG_DEBUG, "Seal_ski function");
  if (tpm2_kmyth_seal(data, data_len, data_out, data_out_len, NULL, NULL, NULL, NULL, NULL, false))
  {
    pelz_log(LOG_ERR, "Kmyth TPM seal failed");
    return 1;
  }
  return (0);
}

int seal_nkl(uint8_t * data, size_t data_len, uint8_t ** data_out, size_t *data_out_len)
{
  pelz_log(LOG_DEBUG, "Seal_nkl function");        
  sgx_status_t sgx_status = sgx_create_enclave(ENCLAVE_PATH, SGX_DEBUG_FLAG, NULL, NULL, &eid, NULL);
  if (sgx_status != SGX_SUCCESS) {
    pelz_log(LOG_ERR, "Failed to load enclave %s, error code is 0x%x.\n", ENCLAVE_PATH, sgx_status);
    return 1;
  }

  uint16_t key_policy = SGX_KEYPOLICY_MRENCLAVE;
  sgx_attributes_t attribute_mask;

  attribute_mask.flags = 0;
  attribute_mask.xfrm = 0;

  if (kmyth_sgx_seal_nkl(eid, data, data_len, data_out, data_out_len, key_policy, attribute_mask))
  {
    pelz_log(LOG_ERR, "SGX seal failed");
    sgx_destroy_enclave(eid);
    return 1;
  }

  sgx_destroy_enclave(eid);
  return (0);
}

int read_validate(char *filename, uint8_t ** data, size_t *data_len)
{
  pelz_log(LOG_DEBUG, "Read_validate function");       
  // Verify input path exists with read permissions
  if (verifyInputFilePath(filename))
  {
     pelz_log(LOG_ERR, "input path (%s) is not valid ... exiting", filename);
     return 1;
  }

  if (read_bytes_from_file(filename, data, data_len))
  {
     pelz_log(LOG_ERR, "seal input data file read error ... exiting");
     return 1;
  }
  pelz_log(LOG_DEBUG, "read in %zu bytes of data to be wrapped", *data_len);

  // validate non-empty plaintext buffer specified
  if (data_len == 0 || data == NULL)
  {
     pelz_log(LOG_ERR, "no input data ... exiting");
     free(data);
     return 1;
  }
  return 0;
}

int outpath_validate(char *filename, char **outpath, size_t outpath_size, bool tpm)
{
  pelz_log(LOG_DEBUG, "Outpath_validate function");        
  if ((*outpath != NULL) && (outpath_size != 0))
  {        
    return 0;
  }
  else
  {
    if(outpath_create(filename, outpath, tpm))
    {
      return 1;
    }
  }
  return 0;
}

int outpath_create(char *filename, char **outpath, bool tpm)
{
  char *temp_outpath;
  const char *ext;
  const char *TPM_EXT = ".ski";
  const char *NKL_EXT = ".nkl";

  pelz_log(LOG_DEBUG, "Outpath_create function");
  if (tpm)
  {
    ext = TPM_EXT;
  }
  else
  {
    ext = NKL_EXT;
  }

  // If output file not specified, set output path to basename(filename) with
  // a extension in the directory that the application is being run from.
  char *original_fn = basename(filename);

  temp_outpath = (char *) malloc((strlen(original_fn) + strlen(ext) + 1) * sizeof(char));

  // Make sure resultant default file name does not have empty basename
  if (temp_outpath == NULL)
  {
    pelz_log(LOG_ERR, "invalid default filename derived ... exiting");
    free(temp_outpath);
    return 1;
  }

  sprintf(temp_outpath, "%.*s%.*s", (int) strlen(original_fn), original_fn, (int) strlen(ext), ext);
  // Make sure default filename we constructed doesn't already exist
  struct stat st = { 0 };
  if (!stat(temp_outpath, &st))
  {
    pelz_log(LOG_ERR, "default output filename (%s) already exists ... exiting", temp_outpath);
    free(temp_outpath);
    return 1;
  }

  *outpath = temp_outpath;
  pelz_log(LOG_DEBUG, "output file not specified, default = %s", *outpath);
  return 0;
}
