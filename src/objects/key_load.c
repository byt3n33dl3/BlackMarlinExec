#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <pthread.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>
#include <sys/epoll.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <fcntl.h>
#include <uriparser/Uri.h>
#include <kmyth/file_io.h>
#include <kmyth/memory_util.h>

#include "charbuf.h"
#include "pelz_log.h"
#include "key_load.h"
#include "common_table.h"
#include "pelz_request_handler.h"
#include "pelz_uri_helpers.h"
#include "pelz_loaders.h"

#include "sgx_urts.h"
#include "sgx_seal_unseal_impl.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

void ocall_malloc(size_t size, unsigned char **buf)
{
  *buf = (unsigned char *) malloc(size);
}

void ocall_free(void *ptr, size_t len)
{
  secure_memset(ptr, 0, len);
  free(ptr);
}

ExtensionType get_file_ext(char *filename)
{
  charbuf buf;
  size_t period_index = 0;
  size_t ext_len = 0;
  size_t ext_type_len = 4;
  const char *ext_type[2] = { ".nkl", ".ski" };

  if (filename == NULL)
  {
    return NO_EXT;
  }

  buf = new_charbuf(strlen(filename));
  memcpy(buf.chars, filename, buf.len);

  // We know that if filename != NULL then buf.len > 0, so there's
  // no wrap-around concern with buf.len-1.
  period_index = get_index_for_char(buf, '.', (buf.len - 1), 1);
  if (period_index == SIZE_MAX)
  {
    free_charbuf(&buf);
    return NO_EXT;
  }

  ext_len = (buf.len - period_index);
  if (ext_len == 0)
  {
    free_charbuf(&buf);
    return NO_EXT;
  }

  // If buf.chars is null terminated we don't want to include
  // the null terminator in the extension, since we're going
  // to use strlen (applied to one of the ext_type entries)
  // to specify a memcmp length, and strlen won't include
  // the null terminator.
  if (buf.chars[buf.len - 1] == '\0')
  {
    ext_len--;
  }
  pelz_log(LOG_DEBUG, "Finding file extension.");
  if (ext_len != ext_type_len)
  {
    free_charbuf(&buf);
    return NO_EXT;
  }
  else if (memcmp(buf.chars + period_index, ext_type[0], ext_type_len) == 0)
  {
    free_charbuf(&buf);
    return NKL;
  }
  else if (memcmp(buf.chars + period_index, ext_type[1], ext_type_len) == 0)
  {
    free_charbuf(&buf);
    return SKI;
  }
  free_charbuf(&buf);
  return NO_EXT;
}

int key_load(charbuf key_id)
{
  charbuf key;
  int return_value = 1;
  TableResponseStatus status;
  UriUriA key_id_data;
  int sgx_ret;

  const char *error_pos = NULL;
  char *key_uri_to_parse = NULL;

  // URI parser expects a null-terminated string to parse,
  // so we embed the key_id in a 1-longer array and
  // ensure it is null terminated.
  key_uri_to_parse = (char *) calloc(key_id.len + 1, 1);
  if (key_uri_to_parse == NULL)
  {
    return return_value;
  }
  memcpy(key_uri_to_parse, key_id.chars, key_id.len);

  pelz_log(LOG_DEBUG, "Starting Key Load");
  pelz_log(LOG_DEBUG, "Key ID: %.*s", key_id.len, key_id.chars);
  if (uriParseSingleUriA(&key_id_data, (const char *) key_uri_to_parse, &error_pos) != URI_SUCCESS
    || key_id_data.scheme.first == NULL || key_id_data.scheme.afterLast == NULL || error_pos != NULL)
  {
    pelz_log(LOG_ERR, "Key ID URI Parse Error");
    free(key_uri_to_parse);
    return (1);
  }

  URI_SCHEME scheme = get_uri_scheme(key_id_data);

  switch (scheme)
  {
  case FILE_URI:
    {
      char *filename = get_filename_from_key_id(key_id_data);
      uint64_t handle;

      if (filename == NULL)
      {
        pelz_log(LOG_ERR, "Failed to parse filename from URI %s\n", key_uri_to_parse);
        break;
      }

      if (get_file_ext(filename) == NO_EXT)
      {
        if (pelz_load_key_from_file(filename, &key) != 0)
        {
          pelz_log(LOG_ERR, "Failed to read key file %s", filename);
          break;
        }
        sgx_ret = key_table_add_key(eid, &status, key_id, key);
        if (sgx_ret != SGX_SUCCESS)
        {
          pelz_log(LOG_ERR, "ECALL Failure: key_table_add_key");
          break;
        }
        secure_free_charbuf(&key);
      }
      else
      {
        if (pelz_load_file_to_enclave(filename, &handle) != 0)
        {
          pelz_log(LOG_ERR, "Failed to read key file %s", filename);
          break;
        }
        sgx_ret = key_table_add_from_handle(eid, &status, key_id, handle);
        if (sgx_ret != SGX_SUCCESS)
        {
          pelz_log(LOG_ERR, "ECALL Failure: key_table_add_from_handle");
          break;
        }
      }
      free(filename);
      switch (status)
      {
      case ERR:
        {
          pelz_log(LOG_ERR, "Failed to load key to table");
          return_value = 1;
          break;
        }
      case ERR_MEM:
        {
          pelz_log(LOG_ERR, "Key Table memory allocation greater than specified limit.");
          return_value = 1;
          break;
        }
      case RET_FAIL:
        {
          pelz_log(LOG_ERR, "Failure to retrieve data from unseal table.");
          return_value = 1;
          break;
        }
      case ERR_BUF:
        {
          pelz_log(LOG_ERR, "Charbuf creation error.");
          return_value = 1;
          break;
        }
      case ERR_REALLOC:
        {
          pelz_log(LOG_ERR, "Key List Space Reallocation Error");
          return_value = 1;
          break;
        }
      case OK:
        {
          pelz_log(LOG_DEBUG, "Key added to table.");
          return_value = 0;
          break;
        }
      default:
        {
          return_value = 1;
          break;
        }
      }
      break;
    }
  case PELZ_URI:
    {
      pelz_log(LOG_DEBUG, "Pelz Scheme Start");
      charbuf server_name;
      charbuf server_key_id;
      charbuf port;

      if (get_pelz_uri_hostname(key_id_data, &server_name) != 0)
      {
        pelz_log(LOG_ERR, "Failed to extract hostname from pelz uri");
        break;
      }

      if (get_pelz_uri_port(key_id_data, &port) != 0)
      {
        pelz_log(LOG_ERR, "Failed to extract port from pelz uri");
        break;
      }

      if (get_pelz_uri_key_UID(key_id_data, &server_key_id) != 0)
      {
        pelz_log(LOG_ERR, "Failed to extract key UID from pelz uri");
        break;
      }

      pelz_log(LOG_DEBUG, "Common Name: %.*s, %d", server_name.len, server_name.chars, server_name.len);
      pelz_log(LOG_DEBUG, "Port Number: %.*s, %d", port.len, port.chars, port.len);
      pelz_log(LOG_DEBUG, "Key UID: %.*s", server_key_id.len, server_key_id.chars);
      sgx_ret = key_table_add_from_server(eid, &status, key_id, server_name, port, server_key_id);
      if (sgx_ret != SGX_SUCCESS)
      {
        pelz_log(LOG_ERR, "ECALL Failure: key_table_add_from_server");
        break;
      }
      free_charbuf(&server_name);
      free_charbuf(&port);
      free_charbuf(&server_key_id);

      switch (status)
      {
      case ERR:
        {
          pelz_log(LOG_ERR, "Failed to load key to table");
          return_value = 1;
          break;
        }
      case ERR_MEM:
        {
          pelz_log(LOG_ERR, "Key Table memory allocation greater than specified limit.");
          return_value = 1;
          break;
        }
      case ERR_REALLOC:
        {
          pelz_log(LOG_ERR, "Key List Space Reallocation Error");
          return_value = 1;
          break;
        }
      case NO_MATCH:
        {
           pelz_log(LOG_ERR, "Certificate or Private Key not matched");
          return_value = 1;
          break;
        }
      case RET_FAIL:
        {
          pelz_log(LOG_ERR, "Key Retrieve Failure");
          return_value = 1;
          break;
        }
      case OK:
        {
          pelz_log(LOG_DEBUG, "Key added to table.");
          return_value = 0;
          break;
        }
      default:
        {
          return_value = 1;
          break;
        }
      }
      break;
    }
  case URI_SCHEME_UNKNOWN:
    // Intentional fallthrough
  default:
    {
      pelz_log(LOG_ERR, "Scheme not supported");
    }
  }
  free(key_uri_to_parse);
  uriFreeUriMembersA(&key_id_data);
  return return_value;
}

int file_check(const char *file_path)
{
  pelz_log(LOG_DEBUG, "File Check Key ID: %s", file_path);
  if (file_path == NULL)
  {
    pelz_log(LOG_DEBUG, "No file path provided.");
    return (1);
  }
  else if (access(file_path, F_OK) == -1)
  {
    pelz_log(LOG_DEBUG, "File cannot be found.");
    return (1);
  }
  else if (access(file_path, R_OK) == -1)
  {
    pelz_log(LOG_DEBUG, "File cannot be read.");
    return (1);
  }
  return (0);
}
