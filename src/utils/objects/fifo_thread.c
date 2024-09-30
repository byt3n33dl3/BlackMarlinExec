#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <kmyth/formatting_tools.h>

#include "charbuf.h"
#include "pelz_log.h"
#include "pipe_io.h"
#include "parse_pipe_message.h"
#include "pelz_socket.h"
#include "fifo_thread.h"
#include "pelz_service.h"

#include "sgx_urts.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

#define BUFSIZE 1024
#define MODE 0600

int send_table_id_list(char *pipe_name, TableType table_type, const char *resp_msg)
{
  int err = 0;
  char resp_buff[BUFSIZE];
  TableResponseStatus status;
  size_t list_num = 0;
  size_t count;
  charbuf id;
  int fd = -1;
  char end[5] ="END\n";

  fd = open_write_pipe(pipe_name);
  if (fd == -1)
  {
    pelz_log(LOG_ERR, "Error opening pipe");
    return 1;
  }

  table_id_count(eid, &status, table_type, &list_num);
  if (status != OK)
  {
    pelz_log(LOG_ERR, "Error retrieving table count.");
    close(fd);
    return 1;
  }

  sprintf(resp_buff, "%s (%zu)\n", resp_msg, list_num);
  if (write_to_pipe_fd(fd, resp_buff))
  {
    pelz_log(LOG_ERR, "Unable to send response to pelz cmd.");
    close(fd);
    return 1;
  }
  else
  {
    pelz_log(LOG_DEBUG, "Pelz-service responses sent to pelz cmd.");
  }

  for (count = 0; count < list_num; count++)
  {
    table_id(eid, &status, table_type, count, &id);
    if (status != OK)
    {
      pelz_log(LOG_ERR, "Error retrieving table <ID> from index %d.", count);
      err = 1;
      continue;
    }

    sprintf(resp_buff, "%.*s\n", (int) id.len, id.chars);
    if (write_to_pipe_fd(fd, resp_buff))
    {
      pelz_log(LOG_ERR, "Unable to send response to pelz cmd.");
      err = 1;
    }
  }
  if (write_to_pipe_fd(fd, end))
  {
    pelz_log(LOG_ERR, "Unable to send response to pelz cmd.");
    err = 1;
  }
  else
  {
    pelz_log(LOG_DEBUG, "Pelz-service responses sent to pelz cmd.");
  }

  close(fd);
  return err;
}

void *fifo_thread_process(void *arg)
{
  ThreadArgs *threadArgs = (ThreadArgs *) arg;
  pthread_mutex_t lock = threadArgs->lock;

  char *msg = NULL;
  char **tokens;
  size_t num_tokens = 0;
  int ret = 0;
  char resp[BUFSIZE];

  // These messages correspond to each value in the ParseResponseStatus enum
  const char *resp_str[35] =
    { "Invalid pipe command received by pelz-service.",
      "Successfully initiated termination of pelz-service.",
      "Unable to read file",
      "TPM unseal failed",
      "SGX unseal failed",
      "Failure to add cert",
      "Successfully loaded certificate file into pelz-service.",
      "Invalid certificate file, unable to load.",
      "Failure to add private",
      "Successfully loaded private key into pelz-service.",
      "Invalid private key file, unable to load.",
      "Failure to remove cert",
      "Removed cert",
      "Server Table Destroy Failure",
      "All certs removed",
      "Failure to remove key",
      "Removed key",
      "Key Table Destroy Failure",
      "All keys removed",
      "Charbuf creation error.",
      "Unable to load file. Files must originally be in the DER format prior to sealing.",
      "Failure to remove private pkey",
      "Removed private pkey",
      "No entries in Key Table.",
      "Key Table List:",
      "No entries in Server Table.",
      "PKI Certificate List:",
      "Failure to load CA cert",
      "Successfully loaded CA certificate file into pelz-service.",
      "Failure to remove CA cert",
      "Removed CA cert",
      "CA Table Destroy Failure",
      "All CA certs removed",
      "No entries in CA Table.",
      "CA Certificate List:",
  };

  if (mkfifo(PELZSERVICE, MODE) == 0)
  {
    pelz_log(LOG_DEBUG, "pelz named pipe (FIFO) created successfully");
  }
  else if (errno != EEXIST)
  {
    pelz_log(LOG_DEBUG, "Error: %s", strerror(errno));
  }

  // global_pipe_reader_active: boolean indicating pipe monitored for commands
  //   - monitoring is performed in do-while loop below
  //   - checked in socket listener loops (inactive will cause their exit)
  //   - EXIT command will break out of loop (stop monitoring of named pipe)
  //   - failed REMOVE ALL KEYS or REMOVE ALL CERTS will break out of loop 
  //   - this boolean is reset (set to false/inactive) on loop exit
  global_pipe_reader_active = true;

  do
  {
    pthread_mutex_lock(&lock);
    if (read_from_pipe(PELZSERVICE, &msg))
    {
      break;
    }

    /*
     * Tokens come out in the following format:
     *
     * token[0] is the program that called it (e.g., pelz)
     * token[1] is the command parsed below
     * token[2-n] are the command inputs. An example for load cert would be:
     *
     * token[0] = pelz
     * token[1] = 2
     * token[2] = path/to/input
     * token[3] = path/to/output
     *
     */
    if (tokenize_pipe_message(&tokens, &num_tokens, msg, strlen(msg)))
    {
      free(msg);
      pthread_mutex_unlock(&lock);
      continue;
    }
    free(msg);

    ret = parse_pipe_message(tokens, num_tokens);
    switch (ret)
    {
      case KEY_LIST:
        send_table_id_list(tokens[2], KEY, resp_str[ret]);
        break;
      case SERVER_LIST:
        send_table_id_list(tokens[2], SERVER, resp_str[ret]);
        break;
      case CA_LIST:
        send_table_id_list(tokens[2], CA_TABLE, resp_str[ret]);
        break;
      default:
        sprintf(resp, "%s\nEND\n", resp_str[ret]);
        if (write_to_pipe(tokens[2], resp))
        {
          pelz_log(LOG_DEBUG, "Unable to send response to pelz cmd.");
        }
        else
        {
          pelz_log(LOG_DEBUG, "Pelz-service responses sent to pelz cmd.");
        }
    }

    //Free the tokens
    for (size_t i = 0; i < num_tokens; i++)
    {
      free(tokens[i]);
    }
    free(tokens);
    pthread_mutex_unlock(&lock);
    
    if (ret == EXIT || ret == KEK_TAB_DEST_FAIL || ret == CERT_TAB_DEST_FAIL)
    {
      break;
    }
  }
  while (true);
  
  global_pipe_reader_active = false;

  pelz_log(LOG_DEBUG, "Global pipe reader thread exit");
  pthread_exit(NULL);
}
