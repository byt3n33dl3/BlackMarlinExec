#include "charbuf.h"
#include "pelz_request_handler.h"
#include "common_table.h"
#include "cipher/pelz_cipher.h"
#include "pelz_enclave_log.h"
#include "enclave_request_signing.h"
#include "secure_socket_enclave.h"
#include "aes_gcm.h"

#include <openssl/rand.h>

#include "sgx_trts.h"
#include ENCLAVE_HEADER_TRUSTED


RequestResponseStatus pelz_encrypt_request_handler(RequestType request_type, charbuf key_id, charbuf cipher_name, charbuf plain_data, charbuf * cipher_data, charbuf* iv, charbuf* tag, charbuf signature, charbuf cert, uint32_t session_id)
{
  pelz_sgx_log(LOG_DEBUG, "Encrypt Request Handler");
  // Start by checking that the signature validates, if present (and required).
  if(request_type == REQ_ENC_SIGNED)
  {
    if(validate_signature(request_type, key_id, cipher_name, plain_data, *iv, *tag, signature, cert) == 1)
    {
      pelz_sgx_log(LOG_ERR, "Validate Signature failure");
      return SIGNATURE_ERROR;
    }
  }
  size_t index;
  
  unsigned char* cipher_name_string = null_terminated_string_from_charbuf(cipher_name);
  if(cipher_name_string == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Cipher name string missing");
    return ENCRYPT_ERROR;
  }

  if(key_id.chars == NULL || key_id.len == 0)
  {
    pelz_sgx_log(LOG_ERR, "Key ID missing");
    return ENCRYPT_ERROR;
  }
  
  cipher_t cipher_struct = pelz_get_cipher_t_from_string((char*)cipher_name_string);
  free(cipher_name_string);

  if(cipher_struct.cipher_name == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Cipher Name in struct missing");
    return ENCRYPT_ERROR;
  }
  
  pelz_sgx_log(LOG_DEBUG, "KEK Load Check");
  if (table_lookup(KEY, key_id, &index))
  {
    pelz_sgx_log(LOG_ERR, "KEK not loaded");
    return KEK_NOT_LOADED;
  }

  cipher_data_t cipher_data_st;

  if (request_type == REQ_ENC_PROTECTED)
  {
    uint8_t *session_key;
    size_t session_key_size;
    if (get_protection_key(session_id, &session_key, &session_key_size))
    {
      return ENCRYPT_ERROR;
    }

    // Decrypt protected input data
    charbuf decrypt_data = new_charbuf(0);
    if (aes_gcm_decrypt((unsigned char *) session_key, session_key_size,
                        plain_data.chars, plain_data.len,
                        &decrypt_data.chars, &decrypt_data.len))
    {
      free(session_key);
      return ENCRYPT_ERROR;
    }

    // Generate output data
    int ret = cipher_struct.encrypt_fn(key_table.entries[index].value.key.chars,
                                        key_table.entries[index].value.key.len,
                                        decrypt_data.chars,
                                        decrypt_data.len,
                                        &cipher_data_st);
    secure_free_charbuf(&decrypt_data);
    if (ret != 0 || cipher_data_st.cipher_len <= 0 || cipher_data_st.cipher == NULL)
    {
      free(cipher_data_st.cipher);
      free(cipher_data_st.iv);
      free(cipher_data_st.tag);
      free(session_key);
      return ENCRYPT_ERROR;
    }

    // Encrypt protected output data
    charbuf encrypt_data = new_charbuf(0);
    ret = aes_gcm_encrypt((unsigned char *) session_key, session_key_size,
                          cipher_data_st.cipher, cipher_data_st.cipher_len,
                          &encrypt_data.chars, &encrypt_data.len);
    free(cipher_data_st.cipher);
    free(session_key);
    if (ret != 0)
    {
      free(cipher_data_st.iv);
      free(cipher_data_st.tag);
      return ENCRYPT_ERROR;
    }

    cipher_data_st.cipher = encrypt_data.chars;
    cipher_data_st.cipher_len = encrypt_data.len;
  }
  else
  {
    pelz_sgx_log(LOG_DEBUG, "Cipher Encrypt");
    if (cipher_struct.encrypt_fn(key_table.entries[index].value.key.chars,
              key_table.entries[index].value.key.len,
              plain_data.chars,
              plain_data.len,
              &cipher_data_st))
    {
      free(cipher_data_st.cipher);
      free(cipher_data_st.iv);
      free(cipher_data_st.tag);
      pelz_sgx_log(LOG_ERR, "Encrypt Error");
      return ENCRYPT_ERROR;
    }
  }


  // Set up the output for cipher_data_st.cipher first because it's the only
  // one that should always be present and it makes the error handling slightly
  // cleaner to do it first.
  if(cipher_data_st.cipher_len > 0 && cipher_data_st.cipher != NULL)
  {
    ocall_malloc(cipher_data_st.cipher_len, &cipher_data->chars);
    if(cipher_data->chars == NULL)
    {
      free(cipher_data_st.cipher);
      free(cipher_data_st.tag);
      free(cipher_data_st.iv);
      
      cipher_data->len = 0;
      pelz_sgx_log(LOG_ERR, "Cipher data allocation error");
      return ENCRYPT_ERROR;
    }
    cipher_data->len = cipher_data_st.cipher_len;
    memcpy(cipher_data->chars, cipher_data_st.cipher, cipher_data->len);
  }
  else
  {
    free(cipher_data_st.cipher);
    free(cipher_data_st.tag);
    free(cipher_data_st.iv);
    pelz_sgx_log(LOG_ERR, "Cipher data missing");
    return ENCRYPT_ERROR;
  }
  free(cipher_data_st.cipher);

  if(cipher_data_st.iv_len > 0 && cipher_data_st.iv != NULL)
  {
    ocall_malloc(cipher_data_st.iv_len, &iv->chars);
    if(iv->chars == NULL)
    {
      ocall_free(cipher_data->chars, cipher_data->len);
      cipher_data->chars = NULL;
      cipher_data->len = 0;
      
      iv->len = 0;
      
      free(cipher_data_st.iv);
      free(cipher_data_st.tag);
      pelz_sgx_log(LOG_ERR, "IV allocation error");
      return ENCRYPT_ERROR;
    }
    iv->len = cipher_data_st.iv_len;
    memcpy(iv->chars, cipher_data_st.iv, iv->len);
  }
  free(cipher_data_st.iv);

  if(cipher_data_st.tag_len > 0 && cipher_data_st.tag != NULL)
  {
    ocall_malloc(cipher_data_st.tag_len, &tag->chars);
    if(tag->chars == NULL)
    {
      ocall_free(cipher_data->chars, cipher_data->len);
      cipher_data->chars = NULL;
      cipher_data->len = 0;
            
      ocall_free(iv->chars, iv->len);
      iv->chars = NULL;
      iv->len = 0;

      tag->len = 0;

      free(cipher_data_st.tag);
      pelz_sgx_log(LOG_ERR, "Tag allocation error");
      return ENCRYPT_ERROR;
    }
    tag->len = cipher_data_st.tag_len;
    memcpy(tag->chars, cipher_data_st.tag, tag->len);
  }
  free(cipher_data_st.tag);
  pelz_sgx_log(LOG_DEBUG, "Encrypt Request Handler Successful");
  return REQUEST_OK;
}


RequestResponseStatus pelz_decrypt_request_handler(RequestType request_type, charbuf key_id, charbuf cipher_name, charbuf cipher_data, charbuf iv, charbuf tag, charbuf * plain_data, charbuf signature, charbuf cert, uint32_t session_id)
{
  pelz_sgx_log(LOG_DEBUG, "Decrypt Request Handler");
  // Start by checking that the signature validates, if present (and required).
  if(request_type == REQ_DEC_SIGNED)
  {
    if(validate_signature(request_type, key_id, cipher_name, cipher_data, iv, tag, signature, cert) == 1)
    {
      pelz_sgx_log(LOG_ERR, "Validate Signature failure");
      return SIGNATURE_ERROR;
    }
  }
  
  charbuf plain_data_internal;
  size_t index;

  unsigned char* cipher_name_string = null_terminated_string_from_charbuf(cipher_name);
  if(cipher_name_string == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Cipher name string missing");
    return DECRYPT_ERROR;
  }

  if(key_id.chars == NULL || key_id.len == 0)
  {
    pelz_sgx_log(LOG_ERR, "Key ID missing");
    return DECRYPT_ERROR;
  }
  
  cipher_t cipher_struct = pelz_get_cipher_t_from_string((char*)cipher_name_string);
  free(cipher_name_string);

  if(cipher_struct.cipher_name == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Cipher Name in struct missing");
    return DECRYPT_ERROR;
  }

  pelz_sgx_log(LOG_DEBUG, "KEK Load Check");
  if (table_lookup(KEY, key_id, &index))
  {
    pelz_sgx_log(LOG_ERR, "KEK not loaded");
    return KEK_NOT_LOADED;
  }

  cipher_data_t cipher_data_st;
  cipher_data_st.cipher = cipher_data.chars;
  cipher_data_st.cipher_len = cipher_data.len;
  cipher_data_st.iv = iv.chars;
  cipher_data_st.iv_len = iv.len;
  cipher_data_st.tag = tag.chars;
  cipher_data_st.tag_len = tag.len;

  if (request_type == REQ_DEC_PROTECTED)
  {
    size_t session_key_size;
    uint8_t *session_key;
    if (get_protection_key(session_id, &session_key, &session_key_size))
    {
      return DECRYPT_ERROR;
    }

    // Decrypt protected input data
    if (aes_gcm_decrypt((unsigned char *) session_key, session_key_size,
                        cipher_data.chars, cipher_data.len,
                        &cipher_data_st.cipher, &cipher_data_st.cipher_len))
    {
      free(session_key);
      return DECRYPT_ERROR;
    }

    // Generate output data
    charbuf pre_encrypt_data = new_charbuf(0);
    int ret = cipher_struct.decrypt_fn(key_table.entries[index].value.key.chars,
                                        key_table.entries[index].value.key.len,
                                        cipher_data_st,
                                        &pre_encrypt_data.chars,
                                        &pre_encrypt_data.len);
    free(cipher_data_st.cipher);
    if (ret != 0)
    {
      free(session_key);
      return DECRYPT_ERROR;
    }

    // Encrypt protected output data
    charbuf encrypt_data = new_charbuf(0);
    ret = aes_gcm_encrypt((unsigned char *) session_key, session_key_size,
                          pre_encrypt_data.chars, pre_encrypt_data.len,
                          &encrypt_data.chars, &encrypt_data.len);
    free(session_key);
    if (ret != 0)
    {
      return DECRYPT_ERROR;
    }

    plain_data_internal = encrypt_data;
  }
  else
  {
    pelz_sgx_log(LOG_DEBUG, "Cipher Decrypt");
    if(cipher_struct.decrypt_fn(key_table.entries[index].value.key.chars,
              key_table.entries[index].value.key.len,
              cipher_data_st,
              &plain_data_internal.chars,
              &plain_data_internal.len))
    {
      pelz_sgx_log(LOG_ERR, "Decrypt Error");
      return DECRYPT_ERROR;
    }
  }
  
  plain_data->len = plain_data_internal.len;
  ocall_malloc(plain_data->len, &plain_data->chars);
  if(plain_data->chars == NULL)
  {
    plain_data->len = 0;
    free_charbuf(&plain_data_internal);
    pelz_sgx_log(LOG_ERR, "Plain data missing");
    return DECRYPT_ERROR;
  }
  memcpy(plain_data->chars, plain_data_internal.chars, plain_data->len);
  free_charbuf(&plain_data_internal);
  pelz_sgx_log(LOG_DEBUG, "Decrypt Request Handler Successful");
  return REQUEST_OK;
}
