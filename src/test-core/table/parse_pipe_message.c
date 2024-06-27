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
#include <kmyth/file_io.h>
#include <kmyth/memory_util.h>

#include "charbuf.h"
#include "pelz_log.h"
#include "parse_pipe_message.h"
#include "pipe_io.h"
#include "pelz_loaders.h"
#include "common_table.h"
#include "cmd_interface.h"

#include "sgx_urts.h"
#include "sgx_seal_unseal_impl.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

ParseResponseStatus parse_pipe_message(char **tokens, size_t num_tokens)
{
  TableResponseStatus ret;
  charbuf key_id;
  charbuf cert_id;
  uint64_t handle;
  size_t count;

  pelz_log(LOG_DEBUG, "Token num: %d", num_tokens);
  if (num_tokens < 3)
  {
    return INVALID;
  }

  switch (atoi(tokens[1]))
  {
  case CMD_EXIT:
    if (unlink(PELZSERVICE) == 0)
    {
      pelz_log(LOG_INFO, "Pipe deleted successfully");
    }
    else
    {
      pelz_log(LOG_INFO, "Failed to delete the pipe");
    }
    return EXIT;
  case CMD_REMOVE_KEY:
    if (num_tokens != 4)
    {
      return INVALID;
    }

    key_id = new_charbuf(strlen(tokens[3]));
    if (key_id.len != strlen(tokens[3]))
    {
      pelz_log(LOG_ERR, "Charbuf creation error.");
      return ERR_CHARBUF;
    }
    memcpy(key_id.chars, tokens[3], key_id.len);
    table_delete(eid, &ret, KEY, key_id);
    if (ret == NO_MATCH)
    {
      pelz_log(LOG_ERR, "Delete Key ID from Key Table Failure: %.*s", (int) key_id.len, key_id.chars);
      pelz_log(LOG_ERR, "Key ID not found");
      free_charbuf(&key_id);
      return RM_KEK_FAIL;
    }
    else if (ret == ERR_REALLOC)
    {
      pelz_log(LOG_ERR, "Delete Key ID from Key Table Failure: %.*s", (int) key_id.len, key_id.chars);
      pelz_log(LOG_ERR, "Key Table reallocation failure");
      free_charbuf(&key_id);
      return RM_KEK_FAIL;
    }
    else
    {
      pelz_log(LOG_INFO, "Delete Key ID form Key Table: %.*s", (int) key_id.len, key_id.chars);
      free_charbuf(&key_id);
      return RM_KEK;
    }
  case CMD_REMOVE_ALL_KEYS:
    table_destroy(eid, &ret, KEY);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "Key Table Destroy Failure");
      return KEK_TAB_DEST_FAIL;
    }
    pelz_log(LOG_INFO, "Key Table Destroyed and Re-Initialize");
    return RM_KEK_ALL;
  case CMD_LIST_KEYS:
    //Get the number of key table entries
    table_id_count(eid, &ret, KEY, &count);
    if (count == 0)
    {
      pelz_log(LOG_INFO, "No entries in Key Table.");
      return NO_KEY_LIST;
    }
    return KEY_LIST;
  case CMD_LOAD_CERT:
    if (num_tokens != 4)
    {
      return INVALID;
    }

    if (pelz_load_file_to_enclave(tokens[3], &handle))
    {
      pelz_log(LOG_INFO, "Invalid extension for load cert call");
      pelz_log(LOG_DEBUG, "Path: %s", tokens[3]);
      return INVALID_EXT_CERT;
    }
    add_cert_to_table(eid, &ret, SERVER, handle);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "Add cert failure");
      switch (ret)
      {
      case ERR_REALLOC:
        pelz_log(LOG_ERR, "Server Table memory allocation greater then specified limit.");
        break;
      case ERR_BUF:
        pelz_log(LOG_ERR, "Charbuf creation error.");
        break;
      case ERR_X509:
        pelz_log(LOG_ERR, "X509 allocation error.");
        return X509_FAIL;
      case RET_FAIL:
        pelz_log(LOG_ERR, "Failure to retrieve data from unseal table.");
        break;
      case NO_MATCH:
        pelz_log(LOG_ERR, "Cert entry and Server ID lookup do not match.");
        break;
      case MEM_ALLOC_FAIL:
        pelz_log(LOG_ERR, "Cert List Space Reallocation Error");
        break;
      default:
        pelz_log(LOG_ERR, "Server return not defined");
      }
      return ADD_CERT_FAIL;
    }
    return LOAD_CERT;
  case CMD_LOAD_PRIV:
    {
    uint64_t priv_handle;
    uint64_t cert_handle;
    if (num_tokens != 5)
    {
      return INVALID;
    }
    if (pelz_load_file_to_enclave(tokens[3], &priv_handle))
    {
      pelz_log(LOG_INFO, "Invalid extension for load private call");
      pelz_log(LOG_DEBUG, "Path: %s", tokens[3]);
      return INVALID_EXT_PRIV;
    }
    if (pelz_load_file_to_enclave(tokens[4], &cert_handle))
    {
      pelz_log(LOG_INFO, "Invalid extension for load private cal");
      pelz_log(LOG_DEBUG, "Path: %s", tokens[4]);
      return INVALID_EXT_PRIV;
    }
    private_pkey_add(eid, &ret, priv_handle, cert_handle);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "Add private pkey failure");
      switch (ret)
      {
      case ERR_X509:
        pelz_log(LOG_ERR, "X509 allocation error.");
        return X509_FAIL;
      case RET_FAIL:
        pelz_log(LOG_ERR, "Failure to retrieve data from unseal table.");
        break;
      default:
        pelz_log(LOG_ERR, "Private pkey add return not defined");
      }
      return ADD_PRIV_FAIL;
    }
    return LOAD_PRIV;
    }
  case CMD_LIST_CERTS:
    //Get the number of server table entries
    table_id_count(eid, &ret, SERVER, &count);
    if (count == 0)
    {
      pelz_log(LOG_INFO, "No entries in Server Table.");
      return NO_SERVER_LIST;
    }
    return SERVER_LIST;
  case CMD_REMOVE_CERT:
    if (num_tokens != 4)
    {
      return INVALID;
    }
    cert_id = new_charbuf(strlen(tokens[3]));
    if (cert_id.len != strlen(tokens[3]))
    {
      pelz_log(LOG_ERR, "Charbuf creation error.");
      return ERR_CHARBUF;
    }
    memcpy(cert_id.chars, tokens[3], cert_id.len);
    table_delete(eid, &ret, SERVER, cert_id);
    if (ret == NO_MATCH)
    {
      pelz_log(LOG_ERR, "Delete Server ID from Server Table Failure: %.*s", (int) cert_id.len, cert_id.chars);
      pelz_log(LOG_ERR, "Server ID not found");
      free_charbuf(&cert_id);
      return RM_CERT_FAIL;
    }
    else if (ret == ERR_REALLOC)
    {
      pelz_log(LOG_ERR, "Delete Server ID from Server Table Failure: %.*s", (int) cert_id.len, cert_id.chars);
      pelz_log(LOG_ERR, "Server Table reallocation failure");
      free_charbuf(&cert_id);
      return RM_CERT_FAIL;
    }
    else
    {
      pelz_log(LOG_INFO, "Delete Server ID from Server Table: %.*s", (int) cert_id.len, cert_id.chars);
      free_charbuf(&cert_id);
      return RM_CERT;
    }
  case CMD_REMOVE_ALL_CERTS:
    table_destroy(eid, &ret, SERVER);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "Server Table Destroy Failure");
      return CERT_TAB_DEST_FAIL;
    }
    pelz_log(LOG_INFO, "Server Table Destroyed and Re-Initialized");
    return RM_ALL_CERT;
  case CMD_REMOVE_PRIV:
    //Free private pkey to remove pkey
    private_pkey_free(eid, &ret);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "PKEY Free Failure");
      return RM_PRIV_FAIL;
    }

    //Re-initializing pkey so new pkey can be loaded
    private_pkey_init(eid, &ret);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "PKEY Re-init Failure");
      return RM_PRIV_FAIL;
    }
    return RM_PRIV;
  case CMD_LOAD_CA:
    if (num_tokens != 4)
    {
      return INVALID;
    }

    if (pelz_load_file_to_enclave(tokens[3], &handle))
    {
      pelz_log(LOG_INFO, "Invalid extension for ca load call");
      pelz_log(LOG_DEBUG, "Path: %s", tokens[3]);
      return INVALID_EXT_CERT;
    }

    add_cert_to_table(eid, &ret, CA_TABLE, handle);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "Add cert failure");
      switch (ret)
      {
      case ERR_REALLOC:
        pelz_log(LOG_ERR, "CA Table memory allocation greater then specified limit.");
        break;
      case ERR_BUF:
        pelz_log(LOG_ERR, "Charbuf creation error.");
        break;
      case ERR_X509:
        pelz_log(LOG_ERR, "X509 allocation error.");
        return X509_FAIL;
      case RET_FAIL:
        pelz_log(LOG_ERR, "Failure to retrieve data from unseal table.");
        break;
      case NO_MATCH:
        pelz_log(LOG_ERR, "Cert entry and CA ID lookup do not match.");
        break;
      case MEM_ALLOC_FAIL:
        pelz_log(LOG_ERR, "Cert List Space Reallocation Error");
        break;
      default:
        pelz_log(LOG_ERR, "ca_table_add return not defined");
      }
      return LOAD_CA_FAIL;
    }
    return LOAD_CA;
  case CMD_REMOVE_CA:
    if (num_tokens != 4)
    {
      return INVALID;
    }
    cert_id = new_charbuf(strlen(tokens[3]));
    if (cert_id.len != strlen(tokens[3]))
    {
      pelz_log(LOG_ERR, "Charbuf creation error.");
      return ERR_CHARBUF;
    }
    memcpy(cert_id.chars, tokens[3], cert_id.len);
    table_delete(eid, &ret, CA_TABLE, cert_id);
    if (ret == NO_MATCH)
    {
      pelz_log(LOG_ERR, "Delete CA ID from CA Table Failure: %.*s", (int) cert_id.len, cert_id.chars);
      pelz_log(LOG_ERR, "CA ID not found");
      free_charbuf(&cert_id);
      return RM_CA_FAIL;
    }
    else if (ret == ERR_REALLOC)
    {
      pelz_log(LOG_ERR, "Delete CA ID from CA Table Failure: %.*s", (int) cert_id.len, cert_id.chars);
      pelz_log(LOG_ERR, "CA Table reallocation failure");
      free_charbuf(&cert_id);
      return RM_CA_FAIL;
    }
    else
    {
      pelz_log(LOG_INFO, "Delete CA ID from CA Table: %.*s", (int) cert_id.len, cert_id.chars);
      free_charbuf(&cert_id);
      return RM_CA;
    }
  case CMD_REMOVE_ALL_CA:
    table_destroy(eid, &ret, CA_TABLE);
    if (ret != OK)
    {
      pelz_log(LOG_ERR, "CA Table Destroy Failure");
      return RM_CA_ALL_FAIL;
    }
    pelz_log(LOG_INFO, "CA Table Destroyed and Re-Initialized");
    return RM_CA_ALL;
  case CMD_LIST_CA:
    //Get the number of CA table entries
    table_id_count(eid, &ret, CA_TABLE, &count);
    if (count == 0)
    {
      pelz_log(LOG_INFO, "No entries in CA Table.");
      return NO_CA_LIST;
    }
    return CA_LIST;
  default:
    pelz_log(LOG_ERR, "Pipe command invalid: %s %s", tokens[0], tokens[1]);
    return INVALID;
  }

  return INVALID;
}
