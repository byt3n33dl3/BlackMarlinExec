/*
 * charbuf.c
 */

#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <kmyth/memory_util.h>

#include "charbuf.h"

charbuf new_charbuf(size_t len)
{
  charbuf newBuf;

  newBuf.len = 0;
  newBuf.chars = NULL;

  if (len > 0 && len < SIZE_MAX)
  {
    newBuf.chars = (unsigned char *) malloc(len);
    if (newBuf.chars != NULL)
    {
      newBuf.len = len;
    }
  }
  return newBuf;
}

void free_charbuf(charbuf * buf)
{
  if (buf != NULL)
  {
    free(buf->chars);
    buf->chars = NULL;
    buf->len = 0;
  }
}

int cmp_charbuf(charbuf buf1, charbuf buf2)
{
  if (buf1.chars == NULL && buf2.chars == NULL)
  {
    return 0;
  }

  if (buf1.chars == NULL && buf2.chars != NULL)
  {
    return -1;
  }

  if (buf1.chars != NULL && buf2.chars == NULL)
  {
    return 1;
  }

  size_t shorter_len = buf1.len < buf2.len ? buf1.len : buf2.len;
  int ret = memcmp(buf1.chars, buf2.chars, shorter_len);

  // If the buffers are the same length, or have different values
  // in their initial segments the result of the memcmp call gives
  // the comparison.
  if ((buf1.len == buf2.len) || (ret != 0))
  {
    return ret;
  }

  // Otherwise they are the same up to shorter_len and it depends on
  // which buffer is longer.
  return buf1.len < buf2.len ? -1 : 1;
}

void secure_free_charbuf(charbuf * buf)
{
  if (buf != NULL)
  {
    if (buf->chars != NULL)
    {
      secure_memset(buf->chars, 0, buf->len);
    }
    free_charbuf(buf);
  }
}

size_t get_index_for_char(charbuf buf, char c, size_t index, int direction)
{
  if (buf.chars == NULL)
  {
    return SIZE_MAX;
  }
  if (index < buf.len)
  {
    if (direction == 0)
    {
      for (size_t i = index; i < buf.len; i++)
      {
        if (c == buf.chars[i])
        {
          return (i);
        }
      }
    }
    else if (direction == 1)
    {
      // Notice that buf.len is of type size_t, so satisifies buf.len <= SIZE_MAX.
      // Decrementing i, eventually we hit i == 0 (corresponding to checking the
      // first element of the charbuf, so this is valid). One more decrement gives
      // i == SIZE_MAX, which means we've wrapped around. The loop condition detects
      // exactly this circumstance, as i == SIZE_MAX >= buf.len, and so i < buf.len is
      // false.
      for (size_t i = index; i < buf.len; i--)
      {
        if (c == buf.chars[i])
        {
          return (i);
        }
      }
    }
  }
  return SIZE_MAX;
}

charbuf copy_chars_from_charbuf(charbuf buf, size_t index)
{
  charbuf newBuf;

  if (index < buf.len)
  {
    newBuf = new_charbuf((buf.len - index));
    if (newBuf.chars == NULL)
    {
      return newBuf;
    }
    memcpy(newBuf.chars, &buf.chars[index], newBuf.len);
    return newBuf;
  }
  return new_charbuf(0);
}

unsigned char * null_terminated_string_from_charbuf(charbuf buf)
{ 
  if (buf.len > 0 && buf.chars != NULL)
  {
    unsigned char *string;

    string = (unsigned char *) calloc(buf.len + 1, sizeof(char));
    memcpy(string, buf.chars, buf.len);
    return string;
  }
  return NULL;
}
