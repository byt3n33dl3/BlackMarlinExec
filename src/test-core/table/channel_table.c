/*
 * channel_table.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <common_table.h>
#include <channel_table.h>
#include <charbuf.h>
#include <pelz_enclave_log.h>

#include "sgx_trts.h"
#include ENCLAVE_HEADER_TRUSTED
#include "sgx_retrieve_key_impl.h"

ChanTable chan_table = {
  .chan_key = NULL,
  .num_entries = 0
};

TableResponseStatus chan_table_init(size_t entry_num)
{
  chan_table.num_entries = entry_num;
  
  charbuf *temp;

  if ((temp = (charbuf *) calloc(entry_num, sizeof(charbuf))) == NULL)
  {
    pelz_sgx_log(LOG_ERR, "Channel Key List Space Allocation Error");
    return MEM_ALLOC_FAIL;
  }
  else
  {
    chan_table.chan_key = temp;
  }
  return OK;
}

TableResponseStatus chan_table_destroy()
{
  for (unsigned int i = 0; i < chan_table.num_entries; i++)
  {
    if (chan_table.chan_key[i].len != 0)
    {
      secure_free_charbuf(&chan_table.chan_key[i]);
    }
  }

  free(chan_table.chan_key);
  chan_table.chan_key = NULL;
  chan_table.num_entries = 0;
  return OK;
}

TableResponseStatus add_chan_key(int socket_id, charbuf key)
{
  chan_table.chan_key[socket_id] = copy_chars_from_charbuf(key, 0);
  return OK;
}

TableResponseStatus get_chan_key(int socket_id, charbuf *key)
{
  *key = copy_chars_from_charbuf(chan_table.chan_key[socket_id], 0);
  return OK;
}

TableResponseStatus clear_chan_key(int socket_id)
{
  secure_free_charbuf(&chan_table.chan_key[socket_id]);
  return OK;
}
