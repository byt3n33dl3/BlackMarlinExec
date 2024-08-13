/**
 * pelz_socket.c
 */
#include <pelz_socket.h>

#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <pelz_request_handler.h>
#include <charbuf.h>
#include <pelz_log.h>

#define ISVALIDSOCKET(s) ((s) >= 0)
#define TIMEOUTSEC 1
#define TIMEOUTUSEC 0

//Initialization of Socket
int pelz_key_socket_init(int max_request, int port, int *socket_listen_id)
{
  struct addrinfo hints;
  struct addrinfo *bind_address;

  int socket_listen;
  int reuse = 1;
  char portaddr[6];

  pelz_log(LOG_INFO, "Configuring local address...");
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;
  sprintf(portaddr, "%d", port);
  getaddrinfo(0, portaddr, &hints, &bind_address);

  pelz_log(LOG_INFO, "Creating socket...");
  socket_listen = socket(bind_address->ai_family, bind_address->ai_socktype, bind_address->ai_protocol);

  if (!ISVALIDSOCKET(socket_listen))
  {
    pelz_log(LOG_ERR, "socket() failed. (%d)", errno);
    return (1);
  }

  if (setsockopt(socket_listen, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
    pelz_log(LOG_ERR, "setsockopt() failed. (%d)", errno);
    return (1);
  }

  pelz_log(LOG_INFO, "Binding socket to local address...");
  if (bind(socket_listen, bind_address->ai_addr, bind_address->ai_addrlen))
  {
    pelz_log(LOG_ERR, "bind() failed. (%d)", errno);
    return (1);
  }
  freeaddrinfo(bind_address);

  pelz_log(LOG_INFO, "Listening...");
  if (listen(socket_listen, max_request) < 0)
  {
    pelz_log(LOG_ERR, "listen() failed. (%d)", errno);
    return (1);
  }
  *socket_listen_id = socket_listen;
  return (0);
}

int pelz_key_socket_accept(int socket_listen_id, int *socket_id)
{
  struct sockaddr_storage client_address;
  struct timeval timeout;
  fd_set readfds;

  int socket_check;
  int socket_client;
  char address_buffer[100];

  FD_ZERO(&readfds);
  FD_SET(socket_listen_id, &readfds);
  timeout.tv_sec = TIMEOUTSEC;
  timeout.tv_usec = TIMEOUTUSEC;

  socklen_t client_len = sizeof(client_address);

  socket_check = select(socket_listen_id + 1, &readfds, NULL, NULL, &timeout);
  if (socket_check == -1)
  {
    pelz_log(LOG_ERR, "select() error");
    return (1);
  }
  else if (socket_check == 0)
  {
    *socket_id = 0;
    return (0);
  }

  pelz_log(LOG_INFO, "Waiting for connection...");
  socket_client = accept(socket_listen_id, (struct sockaddr *) &client_address, &client_len);
  if (!ISVALIDSOCKET(socket_client))
  {
    pelz_log(LOG_ERR, "accept() failed. (%d)", errno);
    return (1);
  }

  pelz_log(LOG_INFO, "%d::Client is connected...", socket_client);
  getnameinfo((struct sockaddr *) &client_address, client_len, address_buffer, sizeof(address_buffer), 0, 0, NI_NUMERICHOST);
  pelz_log(LOG_DEBUG, "%s", address_buffer);
  *socket_id = (int) socket_client;
  return (0);
}

//Received request from client
int pelz_key_socket_recv(int socket_id, charbuf * message)
{
  char client_request[MAX_SOC_DATA_SIZE];

  pelz_log(LOG_INFO, "%d::Reading request...", socket_id);
  ssize_t bytes_received = recv(socket_id, &client_request, MAX_SOC_DATA_SIZE, 0);

  if (bytes_received == -1)
  {
    pelz_log(LOG_ERR, "%d::Receive request failure.", socket_id);
    return (1);
  }
  else if (bytes_received == 0)
  {
    pelz_log(LOG_ERR, "%d::No message received.", socket_id);
    return (1);
  }

  pelz_log(LOG_INFO, "%d::Received %ld bytes.", socket_id, bytes_received);

  // bytes_received can't be negative because it's a return value of
  // recv, and so the only negative possibility is -1. That means these
  // type conversions are safe.
  *message = new_charbuf((size_t)bytes_received);
  memcpy(message->chars, client_request, (size_t)bytes_received);
  return (0);
}

//Send response to client
int pelz_key_socket_send(int socket_id, charbuf response)
{
  ssize_t bytes_sent = send(socket_id, response.chars, response.len, 0);

  pelz_log(LOG_INFO, "%d::Sent %ld of %d bytes.", socket_id, bytes_sent, (int) response.len);
  return (0);
}

//Check if client closed socket
int pelz_key_socket_check(int socket_id)
{
  char test;

  if (!recv(socket_id, &test, 1, MSG_PEEK))
  {
    pelz_log(LOG_INFO, "%d::Client closed socket.", socket_id);
    return (1);
  }

  return (0);
}

//Close client socket
int pelz_key_socket_close(int socket_id)
{

  pelz_log(LOG_INFO, "%d::Closing connection...", socket_id);
  close(socket_id);
  return (0);
}

//Close server socket
int pelz_key_socket_teardown(int *socket_listen_id)
{
  pelz_log(LOG_INFO, "%d::Closing listening socket...", *socket_listen_id);
  close(*socket_listen_id);
  pelz_log(LOG_INFO, "Closed listening socket: %d", *socket_listen_id);
  return (0);
}
