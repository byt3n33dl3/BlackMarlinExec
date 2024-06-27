/*
 * pelz_key_service.c
 */
#include <pelz_service.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <pthread.h>
#include <time.h>

#include "pelz_socket.h"
#include "pelz_log.h"
#include "fifo_thread.h"
#include "unsecure_socket_thread.h"
#include "secure_socket_thread.h"

bool global_pipe_reader_active = false;

static void *unsecure_thread_wrapper(void *arg)
{
  unsecure_socket_thread(arg);
  pelz_log(LOG_DEBUG, "Unsecure socket thread exit");
  pthread_exit(NULL);
}

static void *secure_thread_wrapper(void *arg)
{
  secure_socket_thread(arg);
  pelz_log(LOG_DEBUG, "Secure socket thread exit");
  pthread_exit(NULL);
}

int pelz_service(int max_requests, int port_open, int port_attested, bool secure)
{
  ThreadArgs secure_thread_args;
  ThreadArgs unsecure_thread_args;
  ThreadArgs fifo_thread_args;

  pthread_t fifo_thread;
  pthread_t secure_thread;
  pthread_t unsecure_thread;
  
  pthread_mutex_t lock;

  pthread_mutex_init(&lock, NULL);

  secure_thread_args.lock = lock;
  secure_thread_args.port = port_attested;
  secure_thread_args.max_requests = max_requests;
  
  unsecure_thread_args.lock = lock;
  unsecure_thread_args.port = port_open;
  unsecure_thread_args.max_requests = max_requests;

  fifo_thread_args.lock = lock;
  
  if (pthread_create(&fifo_thread, NULL, fifo_thread_process, &fifo_thread_args))
  {
    pelz_log(LOG_ERR, "Unable to start thread to monitor named pipe");
    return 1;
  }

  if (pthread_create(&secure_thread, NULL, secure_thread_wrapper, &secure_thread_args))
  {
    pelz_log(LOG_ERR, "Unable to start thread to monitor secure socket");
    return 1;
  }
  pelz_log(LOG_INFO, "Secure Listen Socket Thread %d, %d", (int) secure_thread, port_attested);

  if (!secure)
  {
    if (pthread_create(&unsecure_thread, NULL, unsecure_thread_wrapper, &unsecure_thread_args))
    {
      pelz_log(LOG_ERR, "Unable to start thread to monitor unsecure socket");
      return 1;
    }
    pelz_log(LOG_INFO, "Unsecure Listen Socket Thread %d, %d", (int) unsecure_thread, port_open);
  }
  
  pthread_join(fifo_thread, NULL);
  pthread_join(secure_thread, NULL);
  if(!secure)
  {
    pthread_join(unsecure_thread, NULL);
  }

  pelz_log(LOG_INFO, "Exit Pelz Program");

  //Close and Teardown Socket before ending program
  pthread_mutex_destroy(&lock);
  return 0;
}
