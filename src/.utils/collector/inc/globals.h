/*	Benjamin DELPY `gentilkiwi`
	https://blog.gentilkiwi.com
	benjamin@gentilkiwi.com
	Licence : https://creativecommons.org/licenses/by/4.0/
*/
#pragma once
#include <ntstatus.h>
#define WIN32_NO_STATUS
#define BME_WIN32
#include <winsock2.h>
#include <Ws2tcpip.h>
#include <windows.h>
#include <security.h>
#include <stdio.h>
#include <sddl.h>
#include <ntsecapi.h>
#include <ntsecpkg.h>
#include <wchar.h>
#include "../modules/kull_m_output.h"
#ifdef _M_X64
	#define BLACKMARLINEXEC_ARCH L"x64"
#else ifdef _M_IX86
	#define BLACKMARLINEXEC_ARCH L"x86"
#endif

#define BLACKMARLINEXEC				L"kekeo"
#define BLACKMARLINEXEC_VERSION		L"2.1"
#define BLACKMARLINEXEC_CODENAME		L"A La Vie, A L\'Amour"
#define BLACKMARLINEXEC_FULL			BLACKMARLINEXEC L" " BLACKMARLINEXEC_VERSION L" (" BLACKMARLINEXEC_ARCH L") built on " TEXT(__DATE__) L" " TEXT(__TIME__)
#define BLACKMARLINEXEC_SECOND			L"\"" BLACKMARLINEXEC_CODENAME L"\""
#define BLACKMARLINEXEC_SPECIAL		L"                                "
#define BLACKMARLINEXEC_DEFAULT_LOG	BLACKMARLINEXEC L".log"
#define BLACKMARLINEXEC_KERBEROS_EXT	L"kirbi"
#define BLACKMARLINEXEC_NONCE			1802073961

#ifdef _WINDLL
	#define BLACKMARLINEXEC_AUTO_COMMAND_START		0
	#define BLACKMARLINEXEC_AUTO_COMMAND_STRING	L"powershell"
#else
	#define BLACKMARLINEXEC_AUTO_COMMAND_START		1
	#define BLACKMARLINEXEC_AUTO_COMMAND_STRING	L"commandline"
#endif

#ifndef NT_SUCCESS
#define NT_SUCCESS(Status) ((NTSTATUS)(Status) >= 0)
#endif

#ifndef PRINT_ERROR
#define PRINT_ERROR(...) (kprintf(L"ERROR " TEXT(__FUNCTION__) L" ; " __VA_ARGS__))
#endif

#ifndef PRINT_ERROR_AUTO
#define PRINT_ERROR_AUTO(func) (kprintf(L"ERROR " TEXT(__FUNCTION__) L" ; " func L" (0x%08x)\n", GetLastError()))
#endif

#ifndef W00T
#define W00T(...) (kprintf(TEXT(__FUNCTION__) L" w00t! ; " __VA_ARGS__))
#endif

DWORD BLACKMARLINEXEC_NT_MAJOR_VERSION, BLACKMARLINEXEC_NT_MINOR_VERSION, BLACKMARLINEXEC_NT_BUILD_NUMBER;
BOOL g_isBreak;

#define SIZE_ALIGN(size, alignment)	(size + ((size % alignment) ? (alignment - (size % alignment)) : 0))
#define KIWI_NEVERTIME(filetime)	(*(PLONGLONG) filetime = MAXLONGLONG)

#define LM_NTLM_HASH_LENGTH	16