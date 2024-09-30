/*	Benjamin DELPY `gentilkiwi`
	https://blog.gentilkiwi.com
	benjamin@gentilkiwi.com
	Licence : https://creativecommons.org/licenses/by/4.0/
*/
#pragma once
#include "kuhl_m.h"
#include "../../modules/asn1/kull_m_kerberos_asn1.h"
#include "../../modules/asn1/kull_m_kerberos_asn1_authinfos.h"
#include "../../modules/kull_m_file.h"
#include "../../modules/kull_m_sock.h"
#include "../../modules/kull_m_memory.h"
#include "kerberos/kuhl_m_kerberos_pac.h"
#include "kerberos/kuhl_m_kerberos.h"

typedef BOOL (CALLBACK * PKUHL_M_KERBEROS_GETENCRYPTIONKEYFROMAPREQ) (KULL_M_ASN1_AP_REQ *ApReq, KULL_M_ASN1_EncryptionKey *key, LPVOID UserData);

typedef struct _KUHL_M_KERBEROS_HTTP_THREAD_DATA {
	SOCKET clientSocket;
	SOCKADDR_IN clientAddr;
	KULL_M_ASN1_EncryptionKey *key;
	PCSTR aRedirectHeader;
	//BOOL isRickRoll;
} KUHL_M_KERBEROS_HTTP_THREAD_DATA, *PKUHL_M_KERBEROS_HTTP_THREAD_DATA;

const KUHL_M kuhl_m_tgt;

NTSTATUS kuhl_m_tgt_ask(int argc, wchar_t * argv[]);
NTSTATUS kuhl_m_tgt_pac(int argc, wchar_t * argv[]);
NTSTATUS kuhl_m_tgt_asreq(int argc, wchar_t * argv[]);
NTSTATUS kuhl_m_tgt_deleg(int argc, wchar_t * argv[]);
NTSTATUS kuhl_m_tgt_httpserver(int argc, wchar_t * argv[]);

BOOL kuhl_m_tgt_pac_cred(KULL_M_ASN1__octet1 *buf, KULL_M_ASN1_EncryptionKey *AsRepKey);
BOOL kuhl_m_tgt_asreq_export(DWORD cookie, PFILETIME fTime, PKIWI_AUTH_INFOS authInfo, OssBuf *asReq);

DWORD WINAPI kuhl_m_tgt_httpserver_thread(IN LPVOID lpParameter);
BOOL kuhl_m_tgt_httpserver_decodeAnyToken(KULL_M_ASN1__Any *token, KULL_M_ASN1_EncryptionKey *key);
BOOL kuhl_m_tgt_httpserver_decodeB64NTLMAuth(LPCSTR Scheme, LPCSTR b64, PBYTE *data, DWORD *dataLen);
BOOL kuhl_m_tgt_httpserver_recvForMe(SOCKET clientSocket, LPBYTE *data, DWORD *dataLen);
BOOL kuhl_m_tgt_httpserver_sendForMe(SOCKET clientSocket, USHORT Code, LPCSTR Reason, LPCSTR Header);
PSTR kuhl_m_tgt_httpserver_dealWithHeaders(LPCSTR data, DWORD size, LPCSTR toFind);

BOOL kuhl_m_tgt_deleg_from_negTokenInit(LPCVOID data, LONG dataLen, PKUHL_M_KERBEROS_GETENCRYPTIONKEYFROMAPREQ callback, PVOID userdata);
PBYTE kuhl_m_tgt_deleg_searchDataAferOIDInBuffer(IN LPCVOID data, IN SIZE_T Size);

BOOL CALLBACK kuhl_m_tgt_deleg_EncryptionKeyFromCache(KULL_M_ASN1_AP_REQ *ApReq, KULL_M_ASN1_EncryptionKey *key, LPVOID UserData);
BOOL CALLBACK kuhl_m_tgt_deleg_EncryptionKeyFromTicket(KULL_M_ASN1_AP_REQ *ApReq, KULL_M_ASN1_EncryptionKey *key, LPVOID UserData); // TODO