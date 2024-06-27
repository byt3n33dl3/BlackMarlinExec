/* Note: much of this code is adapted from linux-sgx/SampleCode/LocalAttestation/AppResponder/CPTask.cpp */

#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <kmyth/formatting_tools.h>

#include "charbuf.h"
#include "pelz_log.h"
#include "pelz_socket.h"
#include "pelz_json_parser.h"
#include "key_load.h"
#include "pelz_service.h"
#include "pelz_request_handler.h"
#include "secure_socket_thread.h"
#include "secure_socket_ecdh.h"

#include "sgx_urts.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED


static void *secure_process_wrapper(void *arg)
{
  secure_socket_process(arg);
  pthread_exit(NULL);
}

void *secure_socket_thread(void *arg)
{
  ThreadArgs *threadArgs = (ThreadArgs *) arg;
  int port = threadArgs->port;
  int max_requests = threadArgs->max_requests;
  pthread_mutex_t lock = threadArgs->lock;

  ThreadArgs processArgs;
  pthread_t stid[max_requests];
  int socket_id = 0;
  int socket_listen_id;

  //Initializing Socket
  if (pelz_key_socket_init(max_requests, port, &socket_listen_id))
  {
    pelz_log(LOG_ERR, "Socket Initialization Error");
    return NULL;
  }
  pelz_log(LOG_DEBUG, "Secure socket on port %d created with listen_id of %d", port, socket_listen_id);

  do
  {
    if (pelz_key_socket_accept(socket_listen_id, &socket_id))
    {
      pelz_log(LOG_ERR, "Socket Client Connection Error");
      continue;
    }

    if (socket_id == 0)         //This is to reset the while loop if select() times out
    {
      continue;
    }
    pelz_log(LOG_DEBUG, "Secure socket connection accepted");

    if (socket_id > max_requests)
    {
      pelz_log(LOG_WARNING, "%d::Over max socket requests.", socket_id);
      pelz_key_socket_close(socket_id);
      continue;
    }

    processArgs.lock = lock;
    processArgs.socket_id = socket_id;
    if (pthread_create(&stid[socket_id], NULL, secure_process_wrapper, &processArgs) != 0)
    {
      pelz_log(LOG_WARNING, "%d::Failed to create thread.", socket_id);
      pelz_key_socket_close(socket_id);
      continue;
    }

    pelz_log(LOG_INFO, "Secure Socket Thread %d, %d", (int) stid[socket_id], socket_id);
  }
  while (socket_listen_id >= 0 && socket_id <= (max_requests + 1) && global_pipe_reader_active);
  
  pelz_log(LOG_DEBUG, "secure socket (%d) teardown", socket_listen_id);
  pelz_key_socket_teardown(&socket_listen_id);

  return NULL;
}

//Receive message from client
int recv_message(int socket_id, FIFO_MSG ** message)
{
  ssize_t bytes_received;
  FIFO_MSG_HEADER header;
  FIFO_MSG *msg;

  pelz_log(LOG_DEBUG, "%d::Reading message header...", socket_id);

  bytes_received = recv(socket_id, &header, sizeof(FIFO_MSG_HEADER), 0);

  if ((bytes_received <= 0) || ((size_t)bytes_received != sizeof(FIFO_MSG_HEADER)))
  {
    pelz_log(LOG_ERR, "%d::Received incomplete message header.", socket_id);
    return (1);
  }

  if (header.size > MAX_MSG_SIZE)
  {
    pelz_log(LOG_ERR, "%d::Received message with invalid size.", socket_id);
    return (1);
  }

  header.sockfd = socket_id;  // Save current socket fd in header

  msg = (FIFO_MSG *) malloc(sizeof(FIFO_MSG_HEADER) + header.size);

  memcpy(msg, &header, sizeof(FIFO_MSG_HEADER));

  if (header.size > 0)
  {
    bytes_received = recv(socket_id, msg->msgbuf, header.size, 0);
    // If bytes_received is non-negative it can safely be converted to
    // a size_t for the second comparison.
    if ((bytes_received <= 0) || ((size_t)bytes_received != header.size))
    {
      pelz_log(LOG_ERR, "%d::Received incomplete message content.", socket_id);
      return (1);
    }
  }

  pelz_log(LOG_INFO, "%d::Received message with %d bytes.", socket_id, header.size);

  *message = msg;

  return (0);
}

void *secure_socket_process(void *arg)
{
  ThreadArgs *processArgs = (ThreadArgs *) arg;
  int sockfd = processArgs->socket_id;
  pthread_mutex_t lock = processArgs->lock;

  int ret;

  FIFO_MSG * message = NULL;

  while (!pelz_key_socket_check(sockfd))
  {
    //Receiving request and Error Checking
    if (recv_message(sockfd, &message))
    {
      pelz_log(LOG_ERR, "%d::Error receiving message", sockfd);
      while (!pelz_key_socket_check(sockfd))
      {
        continue;
      }
      pelz_key_socket_close(sockfd);
      return NULL;
    }

    pelz_log(LOG_DEBUG, "%d::Request type & Length: %d, %d", sockfd, message->header.type, message->header.size);

    pthread_mutex_lock(&lock);
    ret = handle_message(sockfd, message);
    pthread_mutex_unlock(&lock);

    free(message);
    message = NULL;

    if (ret)
    {
      pelz_log(LOG_ERR, "%d::Error handling message", sockfd);
      while (!pelz_key_socket_check(sockfd))
      {
        continue;
      }
      pelz_key_socket_close(sockfd);
      return NULL;
    }
  }

  return NULL;
}
