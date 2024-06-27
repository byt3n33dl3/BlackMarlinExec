#include <uriparser/Uri.h>
#include <stddef.h>
#include <limits.h>

#include "charbuf.h"
#include "pelz_uri_helpers.h"
#include "pelz_log.h"

URI_SCHEME get_uri_scheme(UriUriA uri)
{
  if (strncmp(uri.scheme.first, "file:", 5) == 0)
  {
    return FILE_URI;
  }
  if (strncmp(uri.scheme.first, "pelz:", 5) == 0)
  {
    return PELZ_URI;
  }
  return URI_SCHEME_UNKNOWN;
}

char *get_filename_from_key_id(UriUriA uri)
{
  if (uri.pathHead == NULL)
  {
    pelz_log(LOG_ERR, "Invalid URI.");
    return NULL;
  }

  ptrdiff_t field_length = uri.pathTail->text.afterLast - uri.pathHead->text.first;

  if (field_length <= 0)
  {
    pelz_log(LOG_ERR, "Invalid URI field length.");
    return NULL;
  }

  // The extra 2 bytes here are to prepend '/' and to append a null byte.
  // The size conversion on field_length is safe because we already know
  // it is non-negative.
  char *filename = (char *) calloc((size_t)field_length + 2, sizeof(char));

  if (filename == NULL)
  {
    pelz_log(LOG_ERR, "Failed to allocate memory for filename.");
    return NULL;
  }
  filename[0] = '/';

  // The type conversion on field_length is safe because if it were negative
  // we already would have errored out.
  memcpy(filename + 1, uri.pathHead->text.first, (size_t)field_length);
  return filename;
}

int get_pelz_uri_hostname(UriUriA uri, charbuf * common_name)
{
  ptrdiff_t field_length;

  // Extract the hostname
  field_length = uri.hostText.afterLast - uri.hostText.first;
  if (field_length <= 0)
  {
    pelz_log(LOG_ERR, "Invalid URI field length.");
    return 1;
  }

  *common_name = new_charbuf((size_t) field_length);
  if (common_name->chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to initialize charbuf.");
    return 1;
  }

  // The type conversion on field_length is safe because if it were
  // negative we already would have errored out.
  memcpy(common_name->chars, uri.hostText.first, (size_t)field_length);
  return 0;
}

int get_pelz_uri_port(UriUriA uri, charbuf *port)
{
  ptrdiff_t field_length;

  // Extract the port
  field_length = uri.pathHead->text.afterLast - uri.pathHead->text.first;
  if (field_length <= 0)
  {
    pelz_log(LOG_ERR, "Invalid URI field length.");
    return 1;
  }

  *port = new_charbuf((size_t) field_length);
  if (port->chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to initialize charbuf.");
    return 1;
  }

  // The type conversion on field_length is safe because if it were
  // negative we already would have errored out.
  memcpy(port->chars, uri.pathHead->text.first, (size_t)field_length);

  long int port_long = strtol((char *) port->chars, NULL, 10);
  if (port_long < 0 || port_long > INT_MAX)
  {
    pelz_log(LOG_ERR, "Invalid port specified: %ld", port_long);
    return 1;
  }

  return 0;
}

int get_pelz_uri_key_UID(UriUriA uri, charbuf * key_id)
{
  ptrdiff_t field_length;

  // Extract the key UID
  field_length = uri.pathHead->next->text.afterLast - uri.pathHead->next->text.first;
  if (field_length <= 0)
  {
    pelz_log(LOG_ERR, "Invalid URI field length.");
    return 1;
  }

  *key_id = new_charbuf((size_t) field_length);
  if (key_id->chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to initialize charbuf.");
    return 1;
  }

  // The type conversion on field_length is safe because were it negative
  // we already would have errored out.
  memcpy(key_id->chars, uri.pathHead->next->text.first, (size_t)field_length);
  return 0;
}

int get_pelz_uri_additional_data(UriUriA uri, charbuf * additional_data)
{
  ptrdiff_t field_length;

  // Extract any additional data
  if (additional_data != NULL)
  {
    field_length = uri.pathTail->text.afterLast - uri.pathHead->next->next->text.first;
    if (field_length <= 0)
    {
      pelz_log(LOG_ERR, "Invalid URI field length.");
      return 1;
    }

    *additional_data = new_charbuf((size_t) field_length);
    if (additional_data->chars == NULL)
    {
      pelz_log(LOG_ERR, "Failed to initialize charbuf.");
      return 1;
    }
    // The type conversion on field_length is safe because if it were negative
    // we'd have already errored-out.
    memcpy(additional_data->chars, uri.pathHead->next->next->text.first, (size_t)field_length);
  }
  return 0;
}
