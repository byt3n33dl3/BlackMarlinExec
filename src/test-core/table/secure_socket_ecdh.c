/*
 * Copyright (C) 2011-2021 Intel Corporation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Intel Corporation nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/* Note: This code is adapted from linux-sgx/SampleCode/LocalAttestation/AppResponder/CPTask.cpp */

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
#include "dh_error_codes.h"

#include "sgx_urts.h"
#include "pelz_enclave.h"
#include ENCLAVE_HEADER_UNTRUSTED

int generate_response(uint32_t session_id);

/* Function Description:
 *  This function responds to initiator enclave's connection request by generating and sending back ECDH message 1
 * Parameter Description:
 *  [input] clientfd: this is client's connection id. After generating ECDH message 1, server would send back response through this connection id.
 * */
int generate_and_send_session_msg1_resp(int clientfd)
{
  int retcode = 0;
  uint32_t status = 0;
  sgx_status_t ret = SGX_SUCCESS;
  SESSION_MSG1_RESP msg1resp;
  FIFO_MSG * fifo_resp = NULL;
  size_t respmsgsize;

  memset(&msg1resp, 0, sizeof(SESSION_MSG1_RESP));

  // call responder enclave to generate ECDH message 1
  ret = session_request(eid, &status, &msg1resp.dh_msg1, &msg1resp.sessionid);
  if (ret != SGX_SUCCESS)
  {
    pelz_log(LOG_ERR, "failed to do ECALL session_request.");
    return -1;
  }

  respmsgsize = sizeof(FIFO_MSG) + sizeof(SESSION_MSG1_RESP);
  fifo_resp = (FIFO_MSG *)malloc(respmsgsize);
  if (!fifo_resp)
  {
    pelz_log(LOG_ERR, "memory allocation failure.");
    return -1;
  }
  memset(fifo_resp, 0, respmsgsize);

  fifo_resp->header.type = FIFO_DH_RESP_MSG1;
  fifo_resp->header.size = sizeof(SESSION_MSG1_RESP);

  memcpy(fifo_resp->msgbuf, &msg1resp, sizeof(SESSION_MSG1_RESP));

  //send message 1 to client
  if (send(clientfd, (char *)fifo_resp, respmsgsize, 0) == -1)
  {
    pelz_log(LOG_ERR, "fail to send msg1 response.");
    retcode = -1;
  }
  free(fifo_resp);
  return retcode;
}

/* Function Description:
 *  This function process ECDH message 2 received from client and send message 3 to client
 * Parameter Description:
 *  [input] clientfd: this is client's connection id
 *  [input] msg2: this contains ECDH message 2 received from client
 * */
int process_exchange_report(int clientfd, SESSION_MSG2 * msg2)
{
  uint32_t status = 0;
  sgx_status_t ret = SGX_SUCCESS;
  FIFO_MSG *response;
  SESSION_MSG3 * msg3;
  size_t msgsize;

  if (!msg2)
    return -1;

  msgsize = sizeof(FIFO_MSG_HEADER) + sizeof(SESSION_MSG3);
  response = (FIFO_MSG *)malloc(msgsize);
  if (!response)
  {
    pelz_log(LOG_ERR, "memory allocation failure");
    return -1;
  }
  memset(response, 0, msgsize);

  response->header.type = FIFO_DH_MSG3;
  response->header.size = sizeof(SESSION_MSG3);

  msg3 = (SESSION_MSG3 *)response->msgbuf;
  msg3->sessionid = msg2->sessionid;

  // call responder enclave to process ECDH message 2 and generate message 3
  ret = exchange_report(eid, &status, &msg2->dh_msg2, &msg3->dh_msg3, msg2->sessionid);
  if (ret != SGX_SUCCESS)
  {
    pelz_log(LOG_ERR, "EnclaveResponse_exchange_report failure.");
    free(response);
    return -1;
  }

  // send ECDH message 3 to client
  if (send(clientfd, (char *)response, msgsize, 0) == -1)
  {
    pelz_log(LOG_ERR, "server_send() failure.");
    free(response);
    return -1;
  }

  free(response);

  return 0;
}

/* Function Description:
 *  This function process received message communication from client
 * Parameter Description:
 *  [input] clientfd: this is client's connection id
 *  [input] req_msg: this is pointer to received message from client
 * */
int process_msg_transfer(int clientfd, FIFO_MSGBODY_REQ *req_msg)
{
  uint32_t status = 0;
  sgx_status_t ret = SGX_SUCCESS;
  secure_message_t *resp_message = NULL;
  FIFO_MSG * fifo_resp = NULL;
  size_t resp_message_size;
  size_t resp_message_max_size;

  if (!req_msg)
  {
    pelz_log(LOG_ERR, "invalid parameter.");
    return -1;
  }

  ret = handle_incoming_msg(eid, &status, (secure_message_t *)req_msg->buf, req_msg->size, req_msg->session_id);
  if (ret != SGX_SUCCESS || status != SUCCESS)
  {
    pelz_log(LOG_ERR, "handle_incoming_msg error.");
    return -1;
  }

  // Call Pelz request message handler
  ret = generate_response(req_msg->session_id);
  if(ret)
  {
    return -1;
  }

  resp_message_max_size = sizeof(secure_message_t) + req_msg->max_payload_size;

  ret = handle_outgoing_msg(eid, &status, req_msg->max_payload_size, &resp_message, &resp_message_size, resp_message_max_size, req_msg->session_id);
  if (ret != SGX_SUCCESS || status != SUCCESS)
  {
    pelz_log(LOG_ERR, "handle_outgoing_msg error.");
    return -1;
  }

  fifo_resp = (FIFO_MSG *)malloc(sizeof(FIFO_MSG) + resp_message_size);
  if (!fifo_resp)
  {
    pelz_log(LOG_ERR, "memory allocation failure.");
    free(resp_message);
    return -1;
  }
  memset(fifo_resp, 0, sizeof(FIFO_MSG) + resp_message_size);

  fifo_resp->header.type = FIFO_DH_MSG_RESP;
  fifo_resp->header.size = resp_message_size;
  memcpy(fifo_resp->msgbuf, resp_message, resp_message_size);

  free(resp_message);

  pelz_log(LOG_DEBUG, "sending %d byte message", resp_message_size);
  if (send(clientfd, (char *)fifo_resp, sizeof(FIFO_MSG) + resp_message_size, 0) == -1)
  {
    pelz_log(LOG_ERR, "server_send() failure.");
    free(fifo_resp);
    return -1;
  }
  free(fifo_resp);

  return 0;
}

/* Function Description: This is process session close request from client
 * Parameter Description:
 *  [input] clientfd: this is client connection id
 *  [input] close_req: this is pointer to client's session close request
 * */
int process_close_req(int clientfd, SESSION_CLOSE_REQ * close_req)
{
  uint32_t status = 0;
  sgx_status_t ret = SGX_SUCCESS;
  FIFO_MSG close_ack;

  if (!close_req)
    return -1;

  // call responder enclave to close this session
  ret = end_session(eid, &status, close_req->session_id);
  if (ret != SGX_SUCCESS)
    return -1;

  // send back response
  close_ack.header.type = FIFO_DH_CLOSE_RESP;
  close_ack.header.size = 0;

  if (send(clientfd, (char *)&close_ack, sizeof(FIFO_MSG), 0) == -1)
  {
    pelz_log(LOG_ERR, "server_send() failure.");
    return -1;
  }

  return 0;
}

int handle_message(int sockfd, FIFO_MSG * message)
{
  switch (message->header.type)
  {
    case FIFO_DH_REQ_MSG1:
    {
      // process ECDH session connection request
      if (generate_and_send_session_msg1_resp(sockfd) != 0)
      {
        pelz_log(LOG_ERR, "failed to generate and send session msg1 resp.");
        return -1;
      }
    }
    break;

    case FIFO_DH_MSG2:
    {
      // process ECDH message 2
      if (process_exchange_report(sockfd, (SESSION_MSG2 *) message->msgbuf) != 0)
      {
        pelz_log(LOG_ERR, "failed to process exchange_report request.");
        return -1;
      }
    }
    break;

    case FIFO_DH_MSG_REQ:
    {
      // process message transfer request
      if (process_msg_transfer(sockfd, (FIFO_MSGBODY_REQ *) message->msgbuf) != 0)
      {
        pelz_log(LOG_ERR, "failed to process message transfer request.");
        return -1;
      }
    }
    break;

    case FIFO_DH_CLOSE_REQ:
    {
      // process message close request
      if (process_close_req(sockfd, (SESSION_CLOSE_REQ *) message->msgbuf) != 0)
      {
        pelz_log(LOG_ERR, "failed to close ecdh session.");
        return -1;
      }
    }
    break;

    default:
    {
      pelz_log(LOG_ERR, "Unknown message.");
    }
    break;
  }

  return 0;
}

charbuf get_error_response(const char *err_message)
{
  int ret_val;
  charbuf message;

  ret_val = error_message_encoder(&message, err_message);
  if (ret_val != EXIT_SUCCESS)
  {
    message = new_charbuf(0);
  }
  pelz_log(LOG_INFO, "Encoded error message: %.*s, %d", (int) message.len, message.chars, (int) message.len);
  return message;
}

/* Function Description: Generates the response from the request message
 * Parameter Description:
 * [input] session_id: id number for current communication session
 * [input] req_data: pointer to decrypted request message
 * [input] req_length: request length
 * [output] response: pointer to response message charbuf, which is initialized in this function
 * 
 * Returns: 0
 */
int handle_pelz_request_msg(uint32_t session_id, char* req_data, size_t req_length, charbuf *response)
{
  int ret_val;
  charbuf message;
  RequestResponseStatus status;
  sgx_status_t sgx_status;
  const char *err_message;
  RequestType request_type = REQ_UNK;

  charbuf key_id = new_charbuf(0);
  charbuf request_sig = new_charbuf(0);
  charbuf requestor_cert = new_charbuf(0);
  charbuf cipher_name = new_charbuf(0);

  charbuf output = new_charbuf(0);
  charbuf input_data = new_charbuf(0);
  charbuf tag = new_charbuf(0);
  charbuf iv = new_charbuf(0);

  //Parse request for processing
  charbuf request = new_charbuf(req_length);
  memcpy(request.chars, req_data, req_length);
  ret_val = request_decoder(request, &request_type, &key_id, &cipher_name, &iv, &tag, &input_data, &request_sig, &requestor_cert);
  if (ret_val != EXIT_SUCCESS)
  {
    err_message = "Missing Data";
    *response = get_error_response(err_message);
    return 0;
  }

  switch(request_type)
  {
  case REQ_ENC:
  case REQ_ENC_SIGNED:
  case REQ_ENC_PROTECTED:
    sgx_status = pelz_encrypt_request_handler(eid, &status, request_type, key_id, cipher_name, input_data, &output, &iv, &tag, request_sig, requestor_cert, session_id);
    if (sgx_status != SGX_SUCCESS)
    {
      status = ENCRYPT_ERROR;
    }
    if (status == KEK_NOT_LOADED)
    {
      ret_val = key_load(key_id);
      if (ret_val == EXIT_SUCCESS)
      {
        sgx_status = pelz_encrypt_request_handler(eid, &status, request_type, key_id, cipher_name, input_data, &output, &iv, &tag, request_sig, requestor_cert, session_id);
        if (sgx_status != SGX_SUCCESS)
        {
          status = ENCRYPT_ERROR;
        }
      }
      else
      {
        status = KEK_LOAD_ERROR;
      }
    }
    break;
  case REQ_DEC:
  case REQ_DEC_SIGNED:
  case REQ_DEC_PROTECTED:
    sgx_status = pelz_decrypt_request_handler(eid, &status, request_type, key_id, cipher_name, input_data, iv, tag, &output, request_sig, requestor_cert, session_id);
    if (sgx_status != SGX_SUCCESS)
    {
      status = DECRYPT_ERROR;
    }
    if (status == KEK_NOT_LOADED)
    {
      ret_val = key_load(key_id);
      if (ret_val == EXIT_SUCCESS)
      {
        sgx_status = pelz_decrypt_request_handler(eid, &status, request_type, key_id, cipher_name, input_data, iv, tag, &output, request_sig, requestor_cert, session_id);
        if (sgx_status != SGX_SUCCESS)
        {
          status = DECRYPT_ERROR;
        }
      }
      else
      {
        status = KEK_LOAD_ERROR;
      }
    }
    break;
  default:
    status = REQUEST_TYPE_ERROR;
  }

  if (status != REQUEST_OK)
  {
    switch (status)
    {
    case KEK_LOAD_ERROR:
      err_message = "Key not added";
      break;
    case KEY_OR_DATA_ERROR:
      err_message = "Key or Data Error";
      break;
    case ENCRYPT_ERROR:
      err_message = "Encrypt Error";
      break;
    case DECRYPT_ERROR:
      err_message = "Decrypt Error";
      break;
    case REQUEST_TYPE_ERROR:
      err_message = "Request Type Error";
      break;
    case CHARBUF_ERROR:
      err_message = "Charbuf Error";
      break;
    default:
      err_message = "Unrecognized response";
    }
    message = get_error_response(err_message);
  }
  else
  {
    ret_val = message_encoder(request_type, key_id, cipher_name, iv, tag, output, &message);
    if (ret_val != EXIT_SUCCESS)
    {
      message = get_error_response("Encode Error");
    }
  }

  secure_free_charbuf(&input_data);
  secure_free_charbuf(&key_id);
  secure_free_charbuf(&output);
  secure_free_charbuf(&iv);
  secure_free_charbuf(&tag);
  secure_free_charbuf(&cipher_name);
  secure_free_charbuf(&request_sig);
  secure_free_charbuf(&requestor_cert);

  *response = message;

  return 0;
}

int generate_response(uint32_t session_id)
{
  sgx_status_t sgx_status;
  ATTESTATION_STATUS status;
  char *request_data;
  size_t request_data_length;
  charbuf response;

  sgx_status = get_request_data(eid, &status, session_id, &request_data, &request_data_length);
  if (sgx_status != SGX_SUCCESS || status != SUCCESS)
  {
    return -1;
  }

  pelz_log(LOG_DEBUG, "Request Message & Length: %.*s, %d", (int) request_data_length, request_data, (int) request_data_length);

  handle_pelz_request_msg(session_id, request_data, request_data_length, &response);
  memset(request_data, 0, request_data_length);
  free(request_data);

  pelz_log(LOG_DEBUG, "Response Message & Length: %.*s, %d", (int) response.len, response.chars, (int) response.len);

  sgx_status = save_response_data(eid, &status, session_id, (char *) response.chars, response.len);
  secure_free_charbuf(&response);
  if (sgx_status != SGX_SUCCESS || status != SUCCESS)
  {
    return -1;
  }

  return 0;
}
