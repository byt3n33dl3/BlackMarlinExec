/*	Benjamin DELPY `gentilkiwi`
	https://blog.gentilkiwi.com
	benjamin@gentilkiwi.com
	Licence : https://creativecommons.org/licenses/by/4.0/
*/
#pragma once
#include "blackmarlinexec_m.h"
#include "../../modules/kull_m_sock.h"
#include "../../modules/kull_m_string.h"
#include "../../modules/kull_m_memory.h"

const blackmarlinexec_M blackmarlinexec_m_server;

NTSTATUS blackmarlinexec_m_server_http(int argc, wchar_t * argv[]);

typedef BOOL (CALLBACK * Pblackmarlinexec_M_SERVER_HTTP_CALLBACK) (PSTR AuthData, LPVOID UserData);

typedef struct _blackmarlinexec_M_SERVER_HTTP_THREAD_DATA {
	SOCKET clientSocket;
	SOCKADDR_IN clientAddr;
	PCSTR aRedirectHeader;
	Pblackmarlinexec_M_SERVER_HTTP_CALLBACK UserCallback;
	PVOID UserData;
} blackmarlinexec_M_SERVER_HTTP_THREAD_DATA, *Pblackmarlinexec_M_SERVER_HTTP_THREAD_DATA;

DWORD WINAPI blackmarlinexec_m_server_http_thread(IN LPVOID lpParameter);
BOOL blackmarlinexec_m_server_http_decodeB64NTLMAuth(LPCSTR Scheme, LPCSTR b64, PBYTE *data, DWORD *dataLen);
BOOL blackmarlinexec_m_server_http_recvForMe(SOCKET clientSocket, LPBYTE *data, DWORD *dataLen);
BOOL blackmarlinexec_m_server_http_sendForMe(SOCKET clientSocket, USHORT Code, LPCSTR Reason, LPCSTR Header);
PSTR blackmarlinexec_m_server_http_dealWithHeaders(LPCSTR data, DWORD size, LPCSTR toFind);