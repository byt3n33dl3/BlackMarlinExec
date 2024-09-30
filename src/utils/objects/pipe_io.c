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
#include "pipe_io.h"
#include "fifo_thread.h"
#include "cmd_interface.h"

#include "sgx_urts.h"
#include "sgx_seal_unseal_impl.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

#define BUFSIZE 1024

int write_to_pipe_fd(int fd, char *msg)
{
  size_t msg_len;
  ssize_t bytes_written;

  msg_len = strlen(msg);
  bytes_written = write(fd, msg, msg_len);
  if ((bytes_written >= 0) && ((size_t)bytes_written == msg_len))
  {
    return 0;
  }
  else
  {
    pelz_log(LOG_ERR, "Error writing to pipe");
    return 1;
  }
}

int write_to_pipe(const char *pipe, char *msg)
{
  int fd;
  int ret;

  fd = open_write_pipe(pipe);
  if (fd == -1)
  {
    pelz_log(LOG_ERR, "Error opening pipe");
    perror("open");
    return 1;
  }

  ret = write_to_pipe_fd(fd, msg);

  if (close(fd) == -1)
  {
    pelz_log(LOG_ERR, "Error closing pipe");
  }
  return ret;
}

int read_from_pipe(const char *pipe, char **msg)
{
  int fd;
  ssize_t ret;
  char buf[BUFSIZE];

  if (file_check(pipe))
  {
    pelz_log(LOG_DEBUG, "Pipe not found");
    pelz_log(LOG_INFO, "Unable to read from pipe.");
    return 1;
  }

  fd = open(pipe, O_RDONLY);
  if (fd == -1)
  {
    pelz_log(LOG_ERR, "Error opening pipe");
    perror("open");
    return 1;
  }

  ret = read(fd, buf, sizeof(buf));
  if (ret < 0)
  {
    pelz_log(LOG_ERR, "Pipe read failed");
  }
  if (close(fd) == -1)
  {
    pelz_log(LOG_ERR, "Error closing pipe");
    return 1;
  }

  if (ret > 0)
  {
    *msg = (char *) calloc((size_t)ret + 1, sizeof(char));
    if(*msg == NULL)
    {
      pelz_log(LOG_ERR, "Failed to allocate memory to return pipe message.");
      return 1;
    }
    memcpy(*msg, buf, (size_t)ret);
  }
  else if (ret < 0)
  {
    pelz_log(LOG_ERR, "Pipe read failed");
    return 1;
  }
  else
  {
    pelz_log(LOG_DEBUG, "No read of pipe");
    *msg = NULL;
  }
  return 0;
}

int read_listener(int fd)
{
  fd_set set;
  struct timeval timeout;
  int rv;
  char msg[BUFSIZE];
  int line_start, line_len, i;
  ssize_t bytes_read;

  FD_ZERO(&set);      // clear the set
  FD_SET(fd, &set);   // add file descriptor to the set

  timeout.tv_sec = 5;
  timeout.tv_usec = 0;

  // Read from the pipe until we see an END terminator, get an error, or time out
  while (true)
  {
    rv = select(fd + 1, &set, NULL, NULL, &timeout);
    if (rv == -1)
    {
      pelz_log(LOG_DEBUG, "Error in timeout of pipe.");
      fprintf(stdout, "Error in timeout of pipe.\n");
      close(fd);
      return 1;
    }
    else if (rv == 0)
    {
      pelz_log(LOG_DEBUG, "No response received from pelz-service.");
      fprintf(stdout, "No response received from pelz-service.\n");
      close(fd);
      return 1;
    }

    bytes_read = read(fd, msg, BUFSIZE);
    if (bytes_read < 0)
    {
      if (errno == EWOULDBLOCK) {
        // This happens occasionally because select is sometimes wrong
        continue;
      }
      pelz_log(LOG_ERR, "Pipe read failed");
      perror("read");
      close(fd);
      return 1;
    }

    // The received data can contain multiple message components separated by newlines
    line_start = 0;
    for (i=0; i<bytes_read; i++)
    {
      if (msg[i] == '\n')
      {
        line_len = i - line_start;

        if (line_len == 3 && memcmp(&msg[line_start], "END", 3) == 0)
        {
          pelz_log(LOG_DEBUG, "Got END message");
          close(fd);
          return 0;
        }
        else
        {
          pelz_log(LOG_DEBUG, "%.*s", line_len, &msg[line_start]);
          fprintf(stdout, "%.*s\n", line_len, &msg[line_start]);
        }

        line_start = i + 1;
      }
      else if (i == bytes_read - 1)
      {
        line_len = i - line_start;
        pelz_log(LOG_ERR, "Incomplete response message - missing newline: %.*s.", line_len, &msg[line_start]);
        close(fd);
        return 1;
      }
    }
  }
}

int tokenize_pipe_message(char ***tokens, size_t * num_tokens, char *message, size_t message_length)
{
  //Copy the string because strtok is destructive
  size_t msg_len = message_length;

  if (message[message_length - 1] != '\n')
  {
    msg_len += 1;
  }
  char *msg = (char *) malloc(msg_len * sizeof(char));

  if (!msg)
  {
    pelz_log(LOG_ERR, "Unable to allocate memory.");
    return 1;
  }
  memcpy(msg, message, message_length);
  msg[msg_len - 1] = '\0';

  size_t token_count = 0;
  size_t start = 0;

  // Skip over leading spaces
  while (msg[start] == ' ' && start < (msg_len - 1))
  {
    start++;
  }

  if (start < (msg_len - 1))
  {
    token_count = 1;

    // The -2 is because we know msg[msg_len-1] == 0.
    for (size_t i = start + 1; i < (msg_len - 2); i++)
    {
      if (msg[i] == ' ' && msg[i + 1] != ' ')
      {
        token_count++;
      }
    }
  }
  else
  {
    pelz_log(LOG_ERR, "Unable to tokenize pipe message: %s", msg);
    free(msg);
    return 1;
  }

  *num_tokens = token_count;
  char **ret_tokens = (char **) malloc(token_count * sizeof(char *));

  if (!ret_tokens)
  {
    pelz_log(LOG_ERR, "Unable to allocate memory.");
    free(msg);
    return 1;
  }
  char *save = msg;
  char *token = strtok(msg, " ");

  ret_tokens[0] = (char *) malloc(strlen(token) * sizeof(char) + 1);
  if (!ret_tokens[0])
  {
    pelz_log(LOG_ERR, "Unable to allocate memory.");
    free(save);
    return 1;
  }
  memcpy(ret_tokens[0], token, strlen(token) + 1);  //copy the '\0'
  for (size_t i = 1; i < token_count; i++)
  {
    token = strtok(NULL, " ");

    if (token == NULL)
    {
      pelz_log(LOG_ERR, "Unable to tokenize pipe message: %s", msg);
      for (size_t j = 0; j < i; j++)
      {
        free(ret_tokens[j]);
      }
      free(ret_tokens);
      free(save);
      return 1;
    }
    ret_tokens[i] = (char *) malloc(strlen(token) * sizeof(char) + 1);
    if (!ret_tokens[i])
    {
      pelz_log(LOG_ERR, "Unable to allocate memory.");
      for (size_t j = 0; j < i; j++)
      {
        free(ret_tokens[j]);
      }
      free(ret_tokens);
      free(save);
      return 1;
    }
    memcpy(ret_tokens[i], token, strlen(token) + 1);  //copy the '\0'
  }
  if (strtok(NULL, " ") != NULL)
  {
    pelz_log(LOG_ERR, "Unable to tokenize pipe message: %s", msg);
    for (size_t i = 0; i < token_count; i++)
    {
      free(ret_tokens[i]);
    }
    free(ret_tokens);
    free(save);
    return 1;
  }
  free(save);
  *tokens = ret_tokens;
  return 0;
}

int open_read_pipe(const char *name)
{
  if (file_check(name))
  {
    pelz_log(LOG_ERR, "Pipe not found");
    return -1;
  }

  return open(name, O_RDONLY | O_NONBLOCK);
}

int open_write_pipe(const char *name)
{
  if (file_check(name))
  {
    pelz_log(LOG_ERR, "Pipe not found");
    return -1;
  }

  // Opening in nonblocking mode will fail if the other end of the pipe is not yet open for reading.
  return open(name, O_WRONLY | O_NONBLOCK);
}

int remove_pipe(const char *name)
{
  //Exit and remove FIFO
  if (unlink(name) == 0)
  {
    pelz_log(LOG_DEBUG, "Pipe deleted successfully");
  }
  else
  {
    pelz_log(LOG_DEBUG, "Failed to delete the pipe");
  }
  return 0;
}
