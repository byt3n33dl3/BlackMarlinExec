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
uint64_t val00;
uint64_t val08;
uint64_t val10;
uint64_t val18;
uint64_t val20;
uint64_t val28;
uint64_t val30;
uint64_t val38;
uint64_t val42;
uint64_t val44;
uint64_t val52;
uint64_t val54;
uint64_t val62;
uint64_t val64;
uint64_t val72;
uint64_t val74;
uint64_t val82;
uint64_t val84;
uint64_t val92;
uint64_t val94;
uint64_t val9A;
uint64_t val9C;
uint64_t valA2;
uint64_t valA4;
uint64_t valAA;
uint64_t valAC;
uint64_t valB2;
uint64_t valB4;
uint64_t valBA;
uint64_t valBC;
uint64_t valC2;
uint64_t valC4;
uint64_t valCA;
uint64_t valCC;
uint64_t valD2;
uint64_t valD4;
uint64_t valDA;
uint64_t valDC;
uint64_t valE2;
uint64_t valE4;
uint64_t valEA;
uint64_t valEC;
uint64_t valF2;
uint64_t valF4;
uint64_t valFA;
uint64_t valFC;
uint64_t val102;
uint64_t val104;
uint64_t val10A;
uint64_t val10C;
uint64_t val112;
uint64_t val114;
uint64_t val11A;
uint64_t val11C;
uint64_t val122;
uint64_t val124;
uint64_t val12A;
uint64_t val12C;
uint64_t val132;
uint64_t val134;
uint64_t val13A;
uint64_t val13C;
uint64_t val142;
uint64_t val144;
uint64_t val14A;
uint64_t val14C;
uint64_t val152;
uint64_t val154;
uint64_t val15A;
uint64_t val15C;
uint64_t val162;
uint64_t val164;
uint64_t val16A;
uint64_t val16C;
uint64_t val172;
uint64_t val174;
uint64_t val17A;
uint64_t val17C;
uint64_t val182;
uint64_t val184;
uint64_t val18A;
uint64_t val18C;
uint64_t val192;
uint64_t val194;
uint64_t val19A;
uint64_t val19C;
uint64_t val1A2;
uint64_t val1A4;
uint64_t val1AA;
uint64_t val1AC;
uint64_t val1B2;
uint64_t val1B4;
uint64_t val1BA;
uint64_t val1BC;
uint64_t val1C2;
uint64_t val1C4;
uint64_t val1CA;
uint64_t val1CC;
uint64_t val1D2;
uint64_t val1D4;
uint64_t val1DA;
uint64_t val1DC;
uint64_t val1E2;
uint64_t val1E4;
uint64_t val1EA;
uint64_t val1EC;
uint64_t val1F2;
uint64_t val1F4;
uint64_t val1FA;
uint64_t val1FC;
uint64_t val202;
uint64_t val204;
uint64_t val20A;
uint64_t val20C;
uint64_t val212;
uint64_t val214;
uint64_t val21A;
uint64_t val21C;
uint64_t val222;
uint64_t val224;
uint64_t val22A;
uint64_t val22C;
uint64_t val232;
uint64_t val234;
uint64_t val23A;
uint64_t val23C;
uint64_t val242;
uint64_t val244;
uint64_t val24A;
uint64_t val24C;
uint64_t val252;
uint64_t val254;
uint64_t val25A;
uint64_t val25C;
uint64_t val262;
uint64_t val264;
uint64_t val26A;
uint64_t val26C;
uint64_t val272;
uint64_t val274;
uint64_t val27A;
uint64_t val27C;
uint64_t val282;
uint64_t val284;
uint64_t val28A;
uint64_t val28C;
uint64_t val292;
uint64_t val294;
uint64_t val29A;
uint64_t val29C;
uint64_t val2A2;
uint64_t val2A4;
uint64_t val2AA;
uint64_t val2AC;
uint64_t val2B2;
uint64_t val2B4;
uint64_t val2BA;
uint64_t val2BC;
uint64_t val2C2;
uint64_t val2C4;
uint64_t val2CA;
uint64_t val2CC;
uint64_t val2D2;
uint64_t val2D4;
uint64_t val2DA;
uint64_t val2DC;
uint64_t val2E2;
uint64_t val2E4;
uint64_t val2EA;
uint64_t val2EC;
uint64_t val2F2;
uint64_t val2F4;
uint64_t val2FA;
uint64_t val2FC;
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