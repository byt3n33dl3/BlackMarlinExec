#include <Windows.h>
#include <stdint.h>
#pragma comment (lib,"psapi")

#define STATUS_INFO_LENGTH_MISMATCH 0xc0000004
#define ObjectThreadType 0x08

typedef struct _SYSTEM_HANDLE_TABLE_ENTRY_INFO
{
	USHORT UniqueProcessId;
	USHORT CreatorBackTraceIndex;
	UCHAR ObjectTypeIndex;
	UCHAR HandleAttributes;
	USHORT HandleValue;
	PVOID Object;
	ULONG GrantedAccess;
} SYSTEM_HANDLE_TABLE_ENTRY_INFO, * PSYSTEM_HANDLE_TABLE_ENTRY_INFO;

typedef struct _SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
{
	PVOID Object;
	HANDLE UniqueProcessId;
	HANDLE HandleValue;
	ULONG GrantedAccess;
	USHORT CreatorBackTraceIndex;
	USHORT ObjectTypeIndex;
	ULONG HandleAttributes;
	ULONG Reserved;
} SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX, * PSYSTEM_HANDLE_TABLE_ENTRY_INFO_EX;

typedef struct _SYSTEM_HANDLE_INFORMATION
{
	ULONG NumberOfHandles;
	SYSTEM_HANDLE_TABLE_ENTRY_INFO Handles[1];
} SYSTEM_HANDLE_INFORMATION, * PSYSTEM_HANDLE_INFORMATION;

typedef struct _SYSTEM_HANDLE_INFORMATION_EX
{
	ULONG_PTR HandleCount;
	ULONG_PTR Reserved;
	SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX Handles[1];
} SYSTEM_HANDLE_INFORMATION_EX, * PSYSTEM_HANDLE_INFORMATION_EX;

typedef enum _SYSTEM_INFORMATION_CLASS {
	SystemHandleInformation = 16,
	SystemExtendedHandleInformation = 0x40,
	SystemBigPoolInformation = 0x42,
	SystemNonPagedPoolInformation = 0x0f
} SYSTEM_INFORMATION_CLASS;

typedef NTSTATUS(WINAPI* _NtQuerySystemInformation)(
	SYSTEM_INFORMATION_CLASS SystemInformationClass,
	PVOID SystemInformation,
	ULONG SystemInformationLength,
	PULONG ReturnLength
	);

typedef NTSTATUS(WINAPI* _NtWriteVirtualMemory)(
	_In_ HANDLE ProcessHandle,
	_In_ PVOID BaseAddress,
	_In_ PVOID Buffer,
	_In_ ULONG NumberOfBytesToWrite,
	_Out_opt_ PULONG NumberOfBytesWritten
	);

typedef struct _IO_STATUS_BLOCK {
	union {
		NTSTATUS Status;
		PVOID    Pointer;
	};
	ULONG_PTR Information;
} IO_STATUS_BLOCK, * PIO_STATUS_BLOCK;

typedef VOID(NTAPI* PIO_APC_ROUTINE)(_In_ PVOID ApcContext, _In_ PIO_STATUS_BLOCK IoStatusBlock, _In_ ULONG Reserved);

 typedef NTSTATUS(WINAPI* _NtFsControlFile)(
	HANDLE           FileHandle,
	HANDLE           Event,
	PIO_APC_ROUTINE  ApcRoutine,
	PVOID            ApcContext,
	PIO_STATUS_BLOCK IoStatusBlock,
	ULONG            FsControlCode,
	PVOID            InputBuffer,
	ULONG            InputBufferLength,
	PVOID            OutputBuffer,
	ULONG            OutputBufferLength
);

 typedef struct _SYSTEM_BIGPOOL_ENTRY
 {
	 union {
		 PVOID VirtualAddress;
		 ULONG_PTR NonPaged : 1;
	 };
	 ULONG_PTR SizeInBytes;
	 union {
		 UCHAR Tag[4];
		 ULONG TagUlong;
	 };
 } SYSTEM_BIGPOOL_ENTRY, * PSYSTEM_BIGPOOL_ENTRY;


 typedef struct _SYSTEM_BIGPOOL_INFORMATION {
	 ULONG Count;
	 SYSTEM_BIGPOOL_ENTRY AllocatedInfo[ANYSIZE_ARRAY];
 } SYSTEM_BIGPOOL_INFORMATION, * PSYSTEM_BIGPOOL_INFORMATION;

 typedef struct _MY_IRP
 {
	uint64_t Type;
	PVOID CurrentProcId;
	uint64_t Flags;
	HANDLE hEvent;
	uint64_t val20;
	uint64_t val24;
	uint64_t val28;
	uint64_t val30;
	uint64_t val38;
	uint64_t val40;
	uint64_t val48;
	uint64_t val50;
	uint64_t val58;
	uint64_t val60;
	uint64_t val68;
	uint64_t val70;
	uint64_t val78;
	uint64_t val80;
	uint64_t val88;
	uint64_t val90;
	uint64_t val98;
	uint64_t valA0;
	uint64_t valA8;
	uint64_t valB0;
 } MY_IRP;

 typedef NTSTATUS(WINAPI* _NtWriteVirtualMemory)(
	 _In_ HANDLE ProcessHandle,
	 _In_ PVOID BaseAddress,
	 _In_ PVOID Buffer,
	 _In_ ULONG NumberOfBytesToWrite,
	 _Out_opt_ PULONG NumberOfBytesWritten
	 );

typedef NTSTATUS(WINAPI* _NtReadVirtualMemory)(
	_In_ HANDLE ProcessHandle,
	_In_ PVOID BaseAddress,
	_Out_ PVOID Buffer,
	_In_ ULONG NumberOfBytesToRead,
	_Out_opt_ PULONG NumberOfBytesRead
	);