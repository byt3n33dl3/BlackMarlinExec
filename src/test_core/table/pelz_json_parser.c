/*
 * json_parser.c
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <cjson/cJSON.h>

#include <pelz_json_parser.h>
#include <pelz_request_handler.h>
#include <charbuf.h>
#include <pelz_log.h>
#include "kmyth/formatting_tools.h"

/**
 * <pre>
 * Helper function to extract non-empty string fields from JSON structs.
 * <pre>
 *
 * @param[in] json       The JSON structure.
 * @param[in] field_name The name of the desired field.
 *
 * @return A charbuf containing the data from the field, or a charbuf
 *         of length 0 on error.
 */
static charbuf get_JSON_string_field(cJSON* json, const char* field_name)
{
  charbuf field;
  if(!cJSON_HasObjectItem(json, field_name) || !cJSON_IsString(cJSON_GetObjectItem(json, field_name)))
  {
    pelz_log(LOG_WARNING, "Missing JSON field %s.", field_name);
    return new_charbuf(0);
  } 
  if(cJSON_GetObjectItemCaseSensitive(json, field_name)->valuestring != NULL)
  {
    field = new_charbuf(strlen(cJSON_GetObjectItemCaseSensitive(json, field_name)->valuestring));
    if(field.len == 0 || field.chars == NULL)
    {  
      pelz_log(LOG_ERR, "Failed to allocate memory to extract JSON field %s.", field_name);
      free_charbuf(&field);
      return new_charbuf(0);
    }
    memcpy(field.chars, cJSON_GetObjectItemCaseSensitive(json, field_name)->valuestring, field.len);
  }
  else
  {
    pelz_log(LOG_WARNING, "No value in JSON field %s.", field_name);
    return new_charbuf(0);
  }
  return field;
}

/**
 * <pre>
 * Helper function to extract fields from JSON structs. 
 * <pre>
 *
 * @param[in]  json       The JSON structure.
 * @param[in]  field_name The name of the desired field.
 * @param[out] value      Integer pointer to hold the extracted value.
 *
 * @return 0 on success, 1 error
 */
static int get_JSON_int_field(cJSON* json, const char* field_name, int* value)
{
  if(!cJSON_HasObjectItem(json, field_name) || !cJSON_IsNumber(cJSON_GetObjectItem(json, field_name)))
  {
    pelz_log(LOG_ERR, "Missing JSON field %s.", field_name);
    return 1;
  }
  *value = cJSON_GetObjectItemCaseSensitive(json, field_name)->valueint;
  return 0;
}


int request_decoder(charbuf request, RequestType * request_type, charbuf * key_id, charbuf* cipher_name, charbuf* iv, charbuf* tag, charbuf * data, charbuf * request_sig, charbuf * requestor_cert)
{
  cJSON *json;
  char *str = NULL;

  charbuf encoded = new_charbuf(0);

  str = (char *) calloc((request.len + 1), sizeof(char));
  memcpy(str, request.chars, request.len);
  json = cJSON_Parse(str);
  free(str);
  if(get_JSON_int_field(json, "request_type", (int*)request_type))
  {
    pelz_log(LOG_ERR, "Missing required JSON key: request_type.");
    cJSON_Delete(json);
    return (1);
  }

  // We always parse out key_id, cipher, and data. Other parsing may
  // happen depending on the request type.
  *key_id = get_JSON_string_field(json, "key_id");
  if(key_id->len == 0 || key_id->chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to extract key_id from JSON.");
    cJSON_Delete(json);
    free_charbuf(key_id);
    return 1;
  }

  *cipher_name = get_JSON_string_field(json, "cipher");
  if(cipher_name->len == 0 || cipher_name->chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to extract cipher from JSON.");
    cJSON_Delete(json);
    free_charbuf(key_id);
    free_charbuf(cipher_name);
    return 1;
  }

  // The following fields are base-64 encoded, so we parse and
  // decode them
  encoded = get_JSON_string_field(json, "data");
  if(encoded.len == 0 || encoded.chars == NULL)
  {
    pelz_log(LOG_ERR, "Failed to extract data from JSON.");
    cJSON_Delete(json);
    free_charbuf(key_id);
    free_charbuf(cipher_name);
    free_charbuf(&encoded);
    return 1;
  }
  decodeBase64Data(encoded.chars, encoded.len, &(data->chars), &(data->len));
  free_charbuf(&encoded);

  // The iv and tag fields are not always present, and at this point
  // we don't know if they're necessary or not so if they're not there
  // we just move on.
  if(*request_type == REQ_DEC || *request_type == REQ_DEC_SIGNED)
  {
    encoded = get_JSON_string_field(json, "iv");
    if(encoded.chars != NULL && encoded.len > 0)
    {
      decodeBase64Data(encoded.chars, encoded.len, &(iv->chars), &(iv->len));
      free_charbuf(&encoded);
    }
    encoded = get_JSON_string_field(json, "tag");
    if(encoded.chars != NULL && encoded.len > 0)
    {
      decodeBase64Data(encoded.chars, encoded.len, &(tag->chars), &(tag->len));
      free_charbuf(&encoded);
    }
  }

  if(*request_type == REQ_ENC_SIGNED || *request_type == REQ_DEC_SIGNED)
  {
    encoded = get_JSON_string_field(json, "request_sig");
    if(encoded.chars == NULL || encoded.len == 0)
    {
      pelz_log(LOG_ERR, "Failed to extract signature from signed request.");
      cJSON_Delete(json);
      free_charbuf(key_id);
      free_charbuf(data);
      free_charbuf(request_sig);
      free_charbuf(iv);
      free_charbuf(tag);
      free_charbuf(cipher_name);
      free_charbuf(&encoded);
      return 1;
    }
    decodeBase64Data(encoded.chars, encoded.len, &(request_sig->chars), &(request_sig->len));
    free_charbuf(&encoded);
    if(request_sig->len == 0 || request_sig->chars == NULL)
    {
      cJSON_Delete(json);
      free_charbuf(key_id);
      free_charbuf(data);
      free_charbuf(request_sig);
      free_charbuf(iv);
      free_charbuf(tag);
      free_charbuf(cipher_name);
      return 1;
    }

    encoded = get_JSON_string_field(json, "requestor_cert");
    decodeBase64Data(encoded.chars, encoded.len, &(requestor_cert->chars), &(requestor_cert->len));
    free_charbuf(&encoded);

    if(requestor_cert->len == 0 || requestor_cert->chars == NULL)
    {
      cJSON_Delete(json);
      free_charbuf(key_id);
      free_charbuf(data);
      free_charbuf(request_sig);
      free_charbuf(requestor_cert);
      free_charbuf(iv);
      free_charbuf(tag);
      free_charbuf(cipher_name);
      return 1;
    }
  }
 
  cJSON_Delete(json);
  return (0);
}

int error_message_encoder(charbuf * message, const char *err_message)
{
  cJSON *root;
  char *tmp = NULL;

  root = cJSON_CreateObject();
  cJSON_AddItemToObject(root, "error", cJSON_CreateString(err_message));
  if (cJSON_IsInvalid(root))
  {
    pelz_log(LOG_ERR, "JSON Message Creation Failed");
    cJSON_Delete(root);
    return (1);
  }
  tmp = cJSON_PrintUnformatted(root);
  *message = new_charbuf(strlen(tmp));
  memcpy(message->chars, tmp, message->len);
  cJSON_Delete(root);
  free(tmp);
  return (0);
}

int message_encoder(RequestType request_type, charbuf key_id, charbuf cipher_name, charbuf iv, charbuf tag, charbuf data, charbuf * message)
{

  cJSON *root;
  char *tmp = NULL;
  charbuf encoded;

  root = cJSON_CreateObject();
  tmp = (char *) calloc((key_id.len + 1), sizeof(char));
  memcpy(tmp, key_id.chars, key_id.len);
  cJSON_AddItemToObject(root, "key_id", cJSON_CreateString(tmp));
  free(tmp);

  tmp = (char*)null_terminated_string_from_charbuf(cipher_name);
  cJSON_AddItemToObject(root, "cipher", cJSON_CreateString(tmp));

  encodeBase64Data(data.chars, data.len, &encoded.chars, &encoded.len);
  tmp = (char *) calloc((encoded.len + 1), sizeof(char));
  memcpy(tmp, encoded.chars, encoded.len);
  cJSON_AddItemToObject(root, "data", cJSON_CreateString(tmp));
  free_charbuf(&encoded);
  free(tmp);
  
  if(request_type == REQ_ENC || request_type == REQ_ENC_SIGNED)
  {
    if(tag.chars != NULL && tag.len != 0)
    {
      encodeBase64Data(tag.chars, tag.len, &encoded.chars, &encoded.len);
      tmp = (char *)calloc(encoded.len+1, sizeof(char));
      memcpy(tmp, encoded.chars, encoded.len);
      cJSON_AddItemToObject(root, "tag", cJSON_CreateString(tmp));
      free_charbuf(&encoded);
      free(tmp);
    }
    if(iv.chars != NULL && iv.len != 0)
    {
      encodeBase64Data(iv.chars, iv.len, &encoded.chars, &encoded.len);
      tmp = (char *)calloc(encoded.len+1, sizeof(char));
      memcpy(tmp, encoded.chars, encoded.len);
      cJSON_AddItemToObject(root, "iv", cJSON_CreateString(tmp));
      free_charbuf(&encoded);
      free(tmp);
    }
  }
  
  if (cJSON_IsInvalid(root))
  {
    pelz_log(LOG_ERR, "JSON Message Creation Failed");
    cJSON_Delete(root);
    return (1);
  }
  tmp = cJSON_PrintUnformatted(root);
  *message = new_charbuf(strlen(tmp));
  memcpy(message->chars, tmp, message->len);
  cJSON_Delete(root);
  free(tmp);
  return (0);
}
