/*
 * common_table.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <kmyth/memory_util.h>

#include <key_load.h>
#include <common_table.h>
#include <pelz_request_handler.h>
#include <charbuf.h>
#include <pelz_enclave_log.h>

#include "sgx_trts.h"
#include ENCLAVE_HEADER_TRUSTED

Table key_table = {
  .entries = NULL,
  .num_entries = 0,
  .mem_size = 0
};

Table server_table = {
  .entries = NULL,
  .num_entries = 0,
  .mem_size = 0
};

Table ca_table = {
  .entries = NULL,
  .num_entries = 0,
  .mem_size = 0
};


Table *get_table_by_type(TableType type)
{
  switch (type)
  {
  case KEY:
    return &key_table;
  case SERVER:
    return &server_table;
  case CA_TABLE:
    return &ca_table;
  default:
    return NULL;
  }
}

//Destroy server table
TableResponseStatus table_destroy(TableType type)
{
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  pelz_sgx_log(LOG_DEBUG, "Table Destroy Function Starting");

  for (unsigned int i = 0; i < table->num_entries; i++)
  {
    if (table->entries[i].id.len != 0)
    {
      free_charbuf(&table->entries[i].id);
    }
    if (type == KEY)
    {
      if (table->entries[i].value.key.len != 0)
      {
        secure_free_charbuf(&table->entries[i].value.key);
      }
    }
    if (type == SERVER || type == CA_TABLE)
    {
      X509_free(table->entries[i].value.cert);
    }
  }

  //Free the storage allocated for the hash table
  free(table->entries);
  table->entries = NULL;
  table->num_entries = 0;
  table->mem_size = 0;

  pelz_sgx_log(LOG_DEBUG, "Table Destroy Function Complete");
  return OK;
}

TableResponseStatus table_delete(TableType type, charbuf id)
{
  size_t index = 0;
  int data_size = 0;
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  for (size_t i = 0; i < table->num_entries; i++)
  {
    if (cmp_charbuf(id, table->entries[i].id) == 0)
    {
      if (type == KEY)
      {
        table->mem_size =
          table->mem_size - ((table->entries[i].value.key.len * sizeof(char)) + (table->entries[i].id.len * sizeof(char)) +
          (2 * sizeof(size_t)));
      }
      else if (type == SERVER || type == CA_TABLE)
      {
        data_size = i2d_X509(table->entries[i].value.cert, NULL);
	if(data_size <= 0)
	{
	  return ERR;
	}
        table->mem_size = table->mem_size - ((table->entries[i].id.len * sizeof(char)) + sizeof(size_t) + (size_t)data_size);
      }
      free_charbuf(&table->entries[i].id);
      if (type == KEY)
      {
        secure_free_charbuf(&table->entries[i].value.key);
      }
      if (type == SERVER || type == CA_TABLE)
      {
        X509_free(table->entries[i].value.cert);
      }
      index = i + 1;
      break;
    }
  }
  if (index == 0)
  {
    pelz_sgx_log(LOG_ERR, "ID not found.");
    return NO_MATCH;
  }
  else if (table->mem_size == 0)
  {
    free(table->entries);
    table->entries = NULL;
    table->num_entries = 0;
  }
  else
  {
    for (size_t i = index; i < table->num_entries; i++)
    {
      table->entries[i - 1] = table->entries[i];
    }
    table->num_entries -= 1;

    Entry *temp;

    if ((temp = (Entry *) realloc(table->entries, (table->num_entries) * sizeof(Entry))) == NULL)
    {
      pelz_sgx_log(LOG_ERR, "List Space Reallocation Error");
      return ERR_REALLOC;
    }
    else
    {
      table->entries = temp;
    }
  }
  return OK;
}

TableResponseStatus table_lookup(TableType type, charbuf id, size_t *index)
{
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  if(id.chars == NULL || id.len == 0)
  {
    return ERR;
  }
  for (size_t i = 0; i < table->num_entries; i++)
  {
    if (cmp_charbuf(id, table->entries[i].id) == 0)
    {
      *index = i;
      return OK;
    }
  }
  return NO_MATCH;
}

TableResponseStatus table_id_count(TableType type, size_t *count)
{
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  *count = table->num_entries;
  return OK;
}

TableResponseStatus table_id(TableType type, size_t index, charbuf *id)
{
  Table *table = get_table_by_type(type);

  if (table == NULL)
  {
    return ERR;
  }

  id->len = table->entries[index].id.len;
  ocall_malloc(id->len, &id->chars);
  memcpy(id->chars, table->entries[index].id.chars, id->len);
  return OK;
}
