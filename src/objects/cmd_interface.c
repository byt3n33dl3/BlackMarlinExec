/*
 * cmd_interface.c
 */
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <limits.h>

#include "cmd_interface.h"
#include "pelz_log.h"
#include "pipe_io.h"

CmdArgValue check_arg(char *arg)
{
  //Checking for value in arg
  if (arg == NULL)
  {
    return EMPTY;
  }

  //Checking for seal command
  if ((memcmp(arg, "seal", 4) == 0) && (strlen(arg) == 4))
  {
    return SEAL;
  }

  //Checking for exit command
  if ((memcmp(arg, "exit", 4) == 0) && (strlen(arg) == 4))
  {
    return EX;
  }

  //Checking for keytable command
  if ((memcmp(arg, "keytable", 8) == 0) && (strlen(arg) == 8))
  {
    return KEYTABLE;
  }

  //Checking for pki command
  if ((memcmp(arg, "pki", 3) == 0) && (strlen(arg) == 3))
  {
    return PKI;
  }

  //Checking for remove command
  if ((memcmp(arg, "remove", 6) == 0) && (strlen(arg) == 6))
  {
    return REMOVE;
  }

  //Checking for list command
  if ((memcmp(arg, "list", 4) == 0) && (strlen(arg) == 4))
  {
    return LIST;
  }

  //Checking for load command
  if ((memcmp(arg, "load", 4) == 0) && (strlen(arg) == 4))
  {
    return LOAD;
  }

  //Checking for cert command
  if ((memcmp(arg, "cert", 4) == 0) && (strlen(arg) == 4))
  {
    return CERT;
  }

  //Checking for private command
  if ((memcmp(arg, "private", 7) == 0) && (strlen(arg) == 7))
  {
    return PRIVATE;
  }

  //Checking for ca keyword
  if ((memcmp(arg, "ca", 2) == 0) && (strlen(arg) == 2))
  {
    return CA;
  }

  return OTHER;        
}

static int msg_cmd(char *pipe, char *msg)
{
  int ret;

  // Ensure the read side of the pipe is opened before the write side.
  // Otherwise, the write side open would fail because it uses nonblocking mode.
  int fd = open_read_pipe(pipe);
  if (fd == -1)
  {
    pelz_log(LOG_ERR, "Error opening pipe for reading");
    perror("open");
    return 1;
  }

  pelz_log(LOG_DEBUG, "Message: %s", msg);
  ret = write_to_pipe(PELZSERVICE, msg);
  if (ret)
  {
    return ret;
  }

  ret = read_listener(fd);
  return ret;
}

int msg_arg(char *pipe, size_t pipe_len, int cmd, char *arg, size_t arg_len)
{
  int ret;

  // Due to the way we encode messages pipe_len and arg_len can't be too big.
  if(pipe_len > INT_MAX || arg_len > INT_MAX)
  {
    return 1;
  }
  char *msg = (char *) calloc((10 + pipe_len + arg_len), sizeof(char));
  if(msg == NULL)
  {
    return 1;
  }
 
  sprintf(msg, "pelz %d %.*s %.*s", cmd, (int)pipe_len, pipe, (int)arg_len, arg);
  ret = msg_cmd(pipe, msg);
  free(msg);
  return ret;
}

int msg_two_arg(char *pipe, size_t pipe_len, int cmd, char *arg, size_t arg_len, char *arg2, size_t arg2_len)
{
  int ret;
  char *msg = (char *) calloc((11 + pipe_len + arg_len + arg2_len), sizeof(char));

  sprintf(msg, "pelz %d %.*s %.*s %.*s", cmd, (int)pipe_len, pipe, (int)arg_len, arg, (int)arg2_len, arg2);
  ret = msg_cmd(pipe, msg);
  free(msg);
  return ret;
}

int msg_list(char *pipe, size_t pipe_len, int cmd)
{
  int ret;

  // Due to the way we encode messages pipe_len can't be too big.
  if(pipe_len > INT_MAX)
  {
    return 1;
  }
  char *msg = (char *) calloc((10 + pipe_len), sizeof(char));
  if(msg == NULL)
  {
    return 1;
  }

  sprintf(msg, "pelz %d %.*s", cmd, (int)pipe_len, pipe);
  ret = msg_cmd(pipe, msg);
  free(msg);
  return ret;
}
