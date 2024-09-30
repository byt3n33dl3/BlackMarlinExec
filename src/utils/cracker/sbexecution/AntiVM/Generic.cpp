#include "pch.h"

#include "Generic.h"

/*
Check if the DLL is loaded in the context of the process
*/
VOID loaded_dlls()
{
	/* Some vars */
	HMODULE hDll;

	/* Array of strings of blacklisted dlls */
	CONST TCHAR* szDlls[] = {
		_T("avghookx.dll"),		// AVG
		_T("avghooka.dll"),		// AVG
		_T("snxhk.dll"),		// Avast
		_T("sbiedll.dll"),		// Sandboxie
		_T("dbghelp.dll"),		// WindBG
		_T("api_log.dll"),		// iDefense Lab
		_T("dir_watch.dll"),	// iDefense Lab
		_T("pstorec.dll"),		// SunBelt Sandbox
		_T("vmcheck.dll"),		// Virtual PC
		_T("wpespy.dll"),		// WPE Pro
		_T("cmdvrt64.dll"),		// Comodo Container
		_T("cmdvrt32.dll"),		// Comodo Container

	};

	WORD dwlength = sizeof(szDlls) / sizeof(szDlls[0]);
	for (int i = 0; i < dwlength; i++)
	{
		TCHAR msg[256] = _T("");
		_stprintf_s(msg, sizeof(msg) / sizeof(TCHAR), _T("Checking if process loaded modules contains: %s "), szDlls[i]);

		/* Check if process loaded modules contains the blacklisted dll */
		hDll = GetModuleHandle(szDlls[i]);
		if (hDll == NULL)
			print_results(FALSE, msg);
		else
			print_results(TRUE, msg);
	}
}

/*
Check if the file name contains any of the following strings.
This is likely an automated malware sandbox.
*/
VOID known_file_names() {

	/* Array of strings of filenames seen in sandboxes */
	CONST TCHAR* szFilenames[] = {
		_T("sample.exe"),
		_T("bot.exe"),		
		_T("sandbox.exe"),		
		_T("malware.exe"),	
		_T("test.exe"),	
		_T("klavme.exe"),		
		_T("myapp.exe"),
		_T("testapp.exe"),

	};

#if defined (ENV64BIT)
	PPEB pPeb = (PPEB)__readgsqword(0x60);

#elif defined(ENV32BIT)
	PPEB pPeb = (PPEB)__readfsdword(0x30);
#endif

	if (!pPeb->ProcessParameters->ImagePathName.Buffer) {
		return;
	}

	// Get the file name from path/
	WCHAR* szFileName = PathFindFileNameW(pPeb->ProcessParameters->ImagePathName.Buffer);
	
	TCHAR msg[256] = _T("");
	WORD dwlength = sizeof(szFilenames) / sizeof(szFilenames[0]);
	for (int i = 0; i < dwlength; i++)
	{
		_stprintf_s(msg, sizeof(msg) / sizeof(TCHAR), _T("Checking if process file name contains: %s "), szFilenames[i]);

		/* Check if file name matches any blacklisted filenames */
		if (StrCmpIW(szFilenames[i], szFileName) != 0)
			print_results(FALSE, msg);
		else
			print_results(TRUE, msg);
	}

	// Some malware do check if the file name is a known hash (like md5 or sha1)
	PathRemoveExtensionW(szFileName);
	_stprintf_s(msg, sizeof(msg) / sizeof(TCHAR), _T("Checking if process file name looks like a hash: %s "), szFileName);
	if ( (wcslen(szFileName) == 32 || wcslen(szFileName) == 40 || wcslen(szFileName) == 64) && IsHexString(szFileName))
		print_results(TRUE, msg);
	else 
		print_results(FALSE, msg);
}

static TCHAR * get_username() {
	TCHAR *username;
	DWORD nSize = (UNLEN + 1);

	username = (TCHAR *) malloc(nSize * sizeof(TCHAR));
	if (!username) {
		return NULL;
	}
	if (0 == GetUserName(username, &nSize)) {
		free(username);
		return NULL;
	}
	return username;
}

/*
Check for usernames associated with sandboxes
*/
VOID known_usernames() {

	/* Array of strings of usernames seen in sandboxes */
	CONST TCHAR* szUsernames[] = {
		/* Checked for by Gootkit
		 * https://www.sentinelone.com/blog/gootkit-banking-trojan-deep-dive-anti-analysis-features/ */
		_T("CurrentUser"),
		_T("Sandbox"),

		/* Checked for by ostap
		 * https://www.bromium.com/deobfuscating-ostap-trickbots-javascript-downloader/ */
		_T("Emily"),
		_T("HAPUBWS"),
		_T("Hong Lee"),
		_T("IT-ADMIN"),
		_T("Johnson"), /* Lastline Sandbox */
		_T("Miller"), /* Lastline Sandbox */
		_T("milozs"),
		_T("Peter Wilson"),
		_T("timmy"),
		_T("user"),

		/* Checked for by Betabot (not including ones from above)
		 * https://www.bromium.com/deobfuscating-ostap-trickbots-javascript-downloader/ */
		_T("sand box"),
		_T("malware"),
		_T("maltest"),
		_T("test user"),

		/* Checked for by Satan (not including ones from above)
		 * https://cofense.com/satan/ */
		_T("virus"),

		/* Checked for by Emotet (not including ones from above)
		 * https://blog.trendmicro.com/trendlabs-security-intelligence/new-emotet-hijacks-windows-api-evades-sandbox-analysis/ */
		_T("John Doe"), /* VirusTotal Cuckoofork Sandbox */
	};
	TCHAR *username;

	if (NULL == (username = get_username())) {
		return;
	}

	TCHAR msg[256];
	WORD dwlength = sizeof(szUsernames) / sizeof(szUsernames[0]);
	for (int i = 0; i < dwlength; i++) {

		_stprintf_s(msg, sizeof(msg) / sizeof(msg[0]), _T("Checking if username matches : %s "), szUsernames[i]);

		/* Do a case-insensitive search for all entries in szHostnames */
		BOOL matched = FALSE;
		if (0 == _tcsicmp(szUsernames[i], username)) {
			matched = TRUE;
		}

		print_results(matched, msg);
	}

	free(username);
}

static TCHAR * get_netbios_hostname() {
	TCHAR *hostname;
	DWORD nSize = (MAX_COMPUTERNAME_LENGTH + 1);

	hostname = (TCHAR *) malloc(nSize * sizeof(TCHAR));
	if (!hostname) {
		return NULL;
	}
	if (0 == GetComputerName(hostname, &nSize)) {
		free(hostname);
		return NULL;
	}
	return hostname;
}

static TCHAR * get_dns_hostname() {
	TCHAR *hostname;
	DWORD nSize = 0;

	GetComputerNameEx(ComputerNameDnsHostname, NULL, &nSize);
	hostname = (TCHAR *) malloc((nSize + 1) * sizeof(TCHAR));
	if (!hostname) {
		return NULL;
	}
	if (0 == GetComputerNameEx(ComputerNameDnsHostname, hostname, &nSize)) {
		free(hostname);
		return NULL;
	}
	return hostname;
}

/*
Check for hostnames associated with sandboxes
*/
VOID known_hostnames() {

	/* Array of strings of hostnames seen in sandboxes */
	CONST TCHAR* szHostnames[] = {
		/* Checked for by Gootkit
		 * https://www.sentinelone.com/blog/gootkit-banking-trojan-deep-dive-anti-analysis-features/ */
		_T("SANDBOX"),
		_T("7SILVIA"),

		/* Checked for by ostap
		 * https://www.bromium.com/deobfuscating-ostap-trickbots-javascript-downloader/ */
		_T("HANSPETER-PC"),
		_T("JOHN-PC"),
		_T("MUELLER-PC"),
		_T("WIN7-TRAPS"),

		/* Checked for by Shifu (not including ones from above)
		 * https://www.mcafee.com/blogs/other-blogs/mcafee-labs/japanese-banking-trojan-shifu-combines-malware-tools */
		_T("FORTINET"),

		/* Checked for by Emotet (not including ones from above)
		 * https://blog.trendmicro.com/trendlabs-security-intelligence/new-emotet-hijacks-windows-api-evades-sandbox-analysis/ */
		_T("TEQUILABOOMBOOM"), /* VirusTotal Cuckoofork Sandbox */
	};
	TCHAR *NetBIOSHostName;
	TCHAR *DNSHostName;

	if (NULL == (NetBIOSHostName = get_netbios_hostname())) {
		return;
	}

	if (NULL == (DNSHostName = get_dns_hostname())) {
		free(NetBIOSHostName);
		return;
	}

	TCHAR msg[256];
	WORD dwlength = sizeof(szHostnames) / sizeof(szHostnames[0]);
	for (int i = 0; i < dwlength; i++) {

		_stprintf_s(msg, sizeof(msg) / sizeof(msg[0]), _T("Checking if hostname matches : %s "), szHostnames[i]);

		/* Do a case-insensitive search for all entries in szHostnames */
		BOOL matched = FALSE;
		if (0 == _tcsicmp(szHostnames[i], NetBIOSHostName)) {
			matched = TRUE;
		}
		else if (0 == _tcsicmp(szHostnames[i], DNSHostName)) {
			matched = TRUE;
		}

		print_results(matched, msg);
	}

	free(NetBIOSHostName);
	free(DNSHostName);
}

/*
Check for a combination of environmental conditions, replicating what malware
could/has used to detect that it's running in a sandbox. */
VOID other_known_sandbox_environment_checks() {
	TCHAR *NetBIOSHostName;
	TCHAR *DNSHostName;
	TCHAR *username;
	BOOL matched;

	if (NULL == (username = get_username())) {
		return;
	}
	if (NULL == (NetBIOSHostName = get_netbios_hostname())) {
		free(username);
		return;
	}

	if (NULL == (DNSHostName = get_dns_hostname())) {
		free(username);
		free(NetBIOSHostName);
		return;
	}
	/* From Emotet
	 * https://blog.trendmicro.com/trendlabs-security-intelligence/new-emotet-hijacks-windows-api-evades-sandbox-analysis/ */

	matched = FALSE;
	if ((0 == StrCmp(username, _T("Wilber"))) &&
		((0 == StrCmpNI(NetBIOSHostName, _T("SC"), 2)) ||
	     (0 == StrCmpNI(NetBIOSHostName, _T("SW"), 2)))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *)_T("Checking whether username is 'Wilber' and NetBIOS name starts with 'SC' or 'SW' "));

	matched = FALSE;
	if ((0 == StrCmp(username, _T("admin"))) && (0 == StrCmp(NetBIOSHostName, _T("SystemIT")))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *)_T("Checking whether username is 'admin' and NetBIOS name is 'SystemIT' "));

	matched = FALSE;
	if ((0 == StrCmp(username, _T("admin"))) && (0 == StrCmp(DNSHostName, _T("KLONE_X64-PC")))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *) _T("Checking whether username is 'admin' and DNS hostname is 'KLONE_X64-PC' "));

	matched = FALSE;
	if ((0 == StrCmp(username, _T("John"))) &&
		(is_FileExists((TCHAR *)_T("C:\\take_screenshot.ps1"))) &&
		(is_FileExists((TCHAR *)_T("C:\\loaddll.exe")))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *)_T("Checking whether username is 'John' and two sandbox files exist "));

	matched = FALSE;
	if ((is_FileExists((TCHAR *)_T("C:\\email.doc"))) &&
		(is_FileExists((TCHAR *)_T("C:\\email.htm"))) &&
		(is_FileExists((TCHAR *)_T("C:\\123\\email.doc"))) &&
		(is_FileExists((TCHAR *)_T("C:\\123\\email.docx")))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *)_T("Checking whether four known sandbox 'email' file paths exist "));

	matched = FALSE;
	if ((is_FileExists((TCHAR *)_T("C:\\a\\foobar.bmp"))) &&
		(is_FileExists((TCHAR *)_T("C:\\a\\foobar.doc"))) &&
		(is_FileExists((TCHAR *)_T("C:\\a\\foobar.gif")))) {
		matched = TRUE;
	}
	print_results(matched, (TCHAR *)_T("Checking whether three known sandbox 'foobar' files exist "));

	free(username);
	free(NetBIOSHostName);
	free(DNSHostName);
}

/*
Detect Hybrid Analysis with mac vendor
*/
BOOL hybridanalysismacdetect()
{
	return check_mac_addr(_T("\x0A\x00\x27"));
}

/*
Number of Processors in VM
*/

BOOL NumberOfProcessors()
{
#if defined (ENV64BIT)
	PULONG ulNumberProcessors = (PULONG)(__readgsqword(0x60) + 0xB8);

#elif defined(ENV32BIT)
	PULONG ulNumberProcessors = (PULONG)(__readfsdword(0x30) + 0x64);

#endif

	if (*ulNumberProcessors < 2)
		return TRUE;
	else
		return FALSE;
}


/*
This trick  involves looking at pointers to critical operating system tables
that are typically relocated on a virtual machine. One such table is the
Interrupt Descriptor Table (IDT), which tells the system where various operating
system interrupt handlers are located in memory. On real machines, the IDT is
located lower in memory than it is on guest (i.e., virtual) machines
PS: Does not seem to work on newer version of VMWare Workstation (Tested on v12)
*/
BOOL idt_trick()
{
	UINT idt_base = get_idt_base();
	if ((idt_base >> 24) == 0xff)
		return TRUE;

	else
		return FALSE;
}

/*
Same for Local Descriptor Table (LDT)
*/
BOOL ldt_trick()
{
	UINT ldt_base = get_ldt_base();

	if (ldt_base == 0xdead0000)
		return FALSE;
	else
		return TRUE; // VMWare detected	
}


/*
Same for Global Descriptor Table (GDT)
*/
BOOL gdt_trick()
{
	UINT gdt_base = get_gdt_base();

	if ((gdt_base >> 24) == 0xff)
		return TRUE; // VMWare detected	

	else
		return FALSE;
}


/*
The instruction STR (Store Task Register) stores the selector segment of the TR
register (Task Register) in the specified operand (memory or other general purpose register).
All x86 processors can manage tasks in the same way as an operating system would do it.
That is, keeping the task state and recovering it when that task is executed again. All
the states of a task are kept in its TSS; there is one TSS per task. How can we know which
is the TSS associated to the execution task? Using STR instruction, due to the fact that
the selector segment that was brought back points into the TSS of the present task.
In all the tests that were done, the value brought back by STR from within a virtual machine
was different to the obtained from a native system, so apparently, it can be used as a another
mechanism of a unique instruction in assembler to detect virtual machines.
*/
BOOL str_trick()
{
	UCHAR mem[4] = { 0, 0, 0, 0 };

#if defined (ENV32BIT)
	__asm str mem;
#endif

	if ((mem[0] == 0x00) && (mem[1] == 0x40))
		return TRUE; // VMWare detected	
	else
		return FALSE;
}


/*
Check number of cores using WMI
*/
BOOL number_cores_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));
	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_Processor"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			// Iterate over our enumator
			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("NumberOfCores"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					if (V_VT(&vtProp) != VT_NULL) {

						// Do our comparaison
						if (vtProp.uintVal < 2) {
							bFound = TRUE;
						}

						// release the current result object
						VariantClear(&vtProp);
					}
				}

				// release class object
				pclsObj->Release();

				// break from while
				if (bFound)
					break;
			}

			// Cleanup
			pEnumerator->Release();
			pSvc->Release();
			pLoc->Release();
			CoUninitialize();
		}
	}

	return bFound;
}

/*
Filter for removable disk, CD-ROM, network drive or RAM disk
*/
BOOL checkDriveType(IWbemClassObject* pclsObj)
{
	if (!pclsObj)
		return FALSE;

	BOOL res = FALSE;
	VARIANT vtDriveType;
	HRESULT hResDriveType;

	hResDriveType = pclsObj->Get(_T("DriveType"), 0, &vtDriveType, NULL, 0);
	if (SUCCEEDED(hResDriveType) && V_VT(&vtDriveType) != VT_NULL)
	{
		if (vtDriveType.uintVal == 2 // removable disk (USB)
			|| vtDriveType.uintVal == 4 // network drive
			|| vtDriveType.uintVal == 5 // CD-ROM
			|| vtDriveType.uintVal == 6 // RAM disk
			)
		{
			res = TRUE;
		}
		VariantClear(&vtDriveType);
	}
	return res;
}

/*
Check hard disk size using WMI
*/
BOOL disk_size_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;
	UINT64 minHardDiskSize = (80ULL * (1024ULL * (1024ULL * (1024ULL))));

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));
	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_LogicalDisk"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			// Iterate over our enumator
			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;
				
				// Don`t check removable disk, network drive CD-ROM and RAM disk
				if (checkDriveType(pclsObj)) {
					pclsObj->Release();
					continue;
				}
				
				// Get the value of the Name property
				hRes = pclsObj->Get(_T("Size"), 0, &vtProp, NULL, 0);
				if (SUCCEEDED(hRes)) {
					if (V_VT(&vtProp) != VT_NULL)
					{
						// convert disk size string to bytes
						errno = 0;
						unsigned long long diskSizeBytes = _tcstoui64_l(vtProp.bstrVal, NULL, 10, _get_current_locale());
						// do the check only if we successfuly got the disk size
						if (errno == 0)
						{
							// Do our comparison
							if (diskSizeBytes < minHardDiskSize) { // Less than 80GB
								bFound = TRUE;
							}
						}	
						// release the current result object
						VariantClear(&vtProp);
					}
				}

				// release class object
				pclsObj->Release();

				// break from while
				if (bFound)
					break;
			}

			// Cleanup
			pEnumerator->Release();
			pSvc->Release();
			pLoc->Release();
			CoUninitialize();
		}
	}

	return bFound;
}


/*
DeviceIoControl works with disks directly rather than partitions (GetDiskFreeSpaceEx)
We can send IOCTL_DISK_GET_LENGTH_INFO code to get the raw byte size of the physical disk
*/
BOOL dizk_size_deviceiocontrol()
{
	HANDLE hDevice = INVALID_HANDLE_VALUE;
	BOOL bResult = FALSE;
	GET_LENGTH_INFORMATION size = { 0 };
	DWORD lpBytesReturned = 0;
	LONGLONG minHardDiskSize = (80LL * (1024LL * (1024LL * (1024LL))));
	LARGE_INTEGER totalDiskSize;
	totalDiskSize.QuadPart = 0LL;

	// This technique requires admin priviliege starting from Windows Vista
	if (!IsElevated() && IsWindowsVistaOrGreater())
		return FALSE;

	// This code tries to get the physical disk(s) associated with the drive that Windows is on.
	// This is not always C:\ or PhysicalDrive0 so we need to do some work to account for multi-disk volumes.
	// By default we fall back to PhysicalDrive0 if any of this fails.

	bool defaultToDrive0 = true;

	// get the Windows system directory
	wchar_t winDirBuffer[MAX_PATH];
	SecureZeroMemory(winDirBuffer, MAX_PATH);
	UINT winDirLen = GetSystemWindowsDirectory(winDirBuffer, MAX_PATH);

	if (winDirLen)
	{
		// get the drive number (0-25 for A-Z) associated with the directory
		int driveNumber = PathGetDriveNumber(winDirBuffer);
		if (driveNumber >= 0)
		{
			// convert the drive number to a root path (e.g. C:\)
			wchar_t driveRootPathBuffer[MAX_PATH];
			SecureZeroMemory(driveRootPathBuffer, MAX_PATH);

			wnsprintf(driveRootPathBuffer, MAX_PATH, _T("\\\\.\\%C:"), _T('A') + driveNumber);

			// open a handle to the volume
			HANDLE hVolume = CreateFile(
				driveRootPathBuffer,
				GENERIC_READ,
				FILE_SHARE_READ | FILE_SHARE_WRITE,
				NULL,
				OPEN_EXISTING,
				FILE_FLAG_BACKUP_SEMANTICS,
				NULL);

			if (hVolume != INVALID_HANDLE_VALUE)
			{
				DWORD extentSize = 8192; //256 VOLUME_DISK_EXTENTS entries
				PVOLUME_DISK_EXTENTS diskExtents = NULL;

				diskExtents = static_cast<PVOLUME_DISK_EXTENTS>(LocalAlloc(LPTR, extentSize));
				if (diskExtents) {

					DWORD dummy = 0;
					BOOL extentsIoctlOK = DeviceIoControl(hVolume, IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS, NULL, 0, diskExtents, extentSize, &dummy, NULL);

					if (extentsIoctlOK && diskExtents->NumberOfDiskExtents > 0)
					{
						// loop through disks associated with this drive
						// we want to sum the disk
						wchar_t physicalPathBuffer[MAX_PATH];

						for (DWORD i = 0; i < diskExtents->NumberOfDiskExtents; i++)
						{
							if (wnsprintf(physicalPathBuffer, MAX_PATH, _T("\\\\.\\PhysicalDrive%u"), diskExtents->Extents[i].DiskNumber) > 0)
							{
								// open the physical disk
								hDevice = CreateFile(
									physicalPathBuffer,
									GENERIC_READ,
									FILE_SHARE_READ,
									NULL,
									OPEN_EXISTING,
									0,
									NULL);

								if (hDevice != INVALID_HANDLE_VALUE)
								{
									// fetch the size info
									bResult = DeviceIoControl(
										hDevice,					// device to be queried
										IOCTL_DISK_GET_LENGTH_INFO, // operation to perform
										NULL, 0,					// no input buffer
										&size, sizeof(GET_LENGTH_INFORMATION),
										&lpBytesReturned,			// bytes returned
										(LPOVERLAPPED)NULL);		// synchronous I/O

									if (bResult)
									{
										// add size :)
										totalDiskSize.QuadPart += size.Length.QuadPart;
										// we've been successful so far, so let's say it's fine
										defaultToDrive0 = false;
									}
									else
									{
										// failed IOCTL call
										defaultToDrive0 = true;
									}

									CloseHandle(hDevice);

									if (!bResult)
										break;
								}
								else
								{
									// failed to open the drive
									defaultToDrive0 = true;
									break;
								}
							}
							else
							{
								// failed to construct the path string for some reason
								defaultToDrive0 = true;
								break;
							}
						}
					}

					LocalFree(diskExtents);
				}

				CloseHandle(hVolume);
			}
		}
	}

	// for some reason we couldn't enumerate the disks associated with the system drive
	// so we'll just check PhysicalDrive0 as a backup
	if (defaultToDrive0)
	{
		hDevice = CreateFile(_T("\\\\.\\PhysicalDrive0"),
			GENERIC_READ,               // no access to the drive
			FILE_SHARE_READ, 			// share mode
			NULL,						// default security attributes
			OPEN_EXISTING,				// disposition
			0,							// file attributes
			NULL);						// do not copy file attributes

		if (hDevice != INVALID_HANDLE_VALUE) {

			if (DeviceIoControl(
				hDevice,					// device to be queried
				IOCTL_DISK_GET_LENGTH_INFO, // operation to perform
				NULL, 0,					// no input buffer
				&size, sizeof(GET_LENGTH_INFORMATION),
				&lpBytesReturned,			// bytes returned
				(LPOVERLAPPED)NULL))		// synchronous I/O
			{
				totalDiskSize.QuadPart = size.Length.QuadPart;
			}
			CloseHandle(hDevice);
		}
	}

	if (totalDiskSize.QuadPart < minHardDiskSize) // 80GB
		bResult = TRUE;
	else
		bResult = FALSE;

	return bResult;
}


BOOL setupdi_diskdrive()
{
	HDEVINFO hDevInfo;
	SP_DEVINFO_DATA DeviceInfoData;
	DWORD i;
	BOOL bFound = FALSE;

	// Create a HDEVINFO with all present devices.
	hDevInfo = SetupDiGetClassDevs((LPGUID)&GUID_DEVCLASS_DISKDRIVE,
		0, // Enumerator
		0,
		DIGCF_PRESENT);

	if (hDevInfo == INVALID_HANDLE_VALUE)
		return FALSE;

	// Enumerate through all devices in Set.
	DeviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

	/* Init some vars */
	DWORD dwPropertyRegDataType;
	LPTSTR buffer = NULL;
	DWORD dwSize = 0;

	for (i = 0; SetupDiEnumDeviceInfo(hDevInfo, i, &DeviceInfoData); i++)
	{
		while (!SetupDiGetDeviceRegistryProperty(hDevInfo, &DeviceInfoData, SPDRP_HARDWAREID,
			&dwPropertyRegDataType, (PBYTE)buffer, dwSize, &dwSize))
		{
			if (GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
				// Change the buffer size.
				if (buffer)LocalFree(buffer);
				// Double the size to avoid problems on 
				// W2k MBCS systems per KB 888609. 
				buffer = (LPTSTR)LocalAlloc(LPTR, dwSize * 2);
				if (buffer == NULL)
					break;
			}
			else
				break;

		}

		if (buffer) {
			// Do our comparison
			if ((StrStrI(buffer, _T("vbox")) != NULL) ||
				(StrStrI(buffer, _T("vmware")) != NULL) ||
				(StrStrI(buffer, _T("qemu")) != NULL) ||
				(StrStrI(buffer, _T("virtual")) != NULL))
			{
				bFound = TRUE;
				break;
			}
		}
	}

	if (buffer)
		LocalFree(buffer);

	//  Cleanup
	SetupDiDestroyDeviceInfoList(hDevInfo);

	if (GetLastError() != NO_ERROR && GetLastError() != ERROR_NO_MORE_ITEMS)
		return FALSE;

	return bFound;
}


/*
Check if there is any mouse movement in the sandbox.
*/
BOOL mouse_movement() {

	POINT positionA = {};
	POINT positionB = {};

	/* Retrieve the position of the mouse cursor, in screen coordinates */
	GetCursorPos(&positionA);

	/* Wait a moment */
	Sleep(5000);

	/* Retrieve the poition gain */
	GetCursorPos(&positionB);

	if ((positionA.x == positionB.x) && (positionA.y == positionB.y))
		/* Probably a sandbox, because mouse position did not change. */
		return TRUE;

	else
		return FALSE;
}


/*
Check for the lack of user input.
This version is slightly different from the original:
https://www.lastline.com/labsblog/malware-evasion-techniques/
It does not run inside an infinite loop (preventing al-khaser to get stuck)
*/
BOOL lack_user_input() {
	int correct_idle_time_counter = 0;
	DWORD current_tick_count = 0, idle_time = 0;
	LASTINPUTINFO last_input_info; // Contains the time of the last input
	last_input_info.cbSize = sizeof(LASTINPUTINFO);

	for (int i = 0; i < 128; ++i) {
		Sleep(0xb);
		// Retrieves the time of the last input event
		if (GetLastInputInfo(&last_input_info)) {
			current_tick_count = GetTickCount();
			if (current_tick_count < last_input_info.dwTime)
				// impossible case unless GetTickCount is manipulated
				return TRUE;
			if (current_tick_count - last_input_info.dwTime < 100) {
				correct_idle_time_counter++;
				if (correct_idle_time_counter >= 10)
					return FALSE;
			}
		}
		else  // GetLastInputInfo must not fail
			return TRUE;
	}
	return TRUE;
}


/*
Check if the machine have enough memory space, usually VM get a small ammount,
one reason if because several VMs are running on the same servers so they can run
more tasks at the same time.
*/
BOOL memory_space()
{
	DWORDLONG ullMinRam = (1024LL * (1024LL * (1024LL * 1LL))); // 1GB
	MEMORYSTATUSEX statex = { 0 };

	statex.dwLength = sizeof(statex);
	GlobalMemoryStatusEx(&statex);

	return (statex.ullTotalPhys < ullMinRam) ? TRUE : FALSE;
}

/*
This trick consists of getting information about total amount of space.
This can be used to expose a sandbox.
*/
BOOL disk_size_getdiskfreespace()
{
	ULONGLONG minHardDiskSize = (80ULL * (1024ULL * (1024ULL * (1024ULL))));
	LPCWSTR pszDrive = NULL;
	BOOL bStatus = FALSE;

	// 64 bits integer, low and high bytes
	ULARGE_INTEGER totalNumberOfBytes;

	// If the function succeeds, the return value is nonzero. If the function fails, the return value is 0 (zero).
	bStatus = GetDiskFreeSpaceEx(pszDrive, NULL, &totalNumberOfBytes, NULL);
	if (bStatus) {
		if (totalNumberOfBytes.QuadPart < minHardDiskSize)  // 80GB
			return TRUE;
	}

	return FALSE;;
}

/*
Sleep and check if time have been accelerated
*/
BOOL accelerated_sleep()
{
	DWORD dwStart = 0, dwEnd = 0, dwDiff = 0;
	DWORD dwMillisecondsToSleep = 60 * 1000;

	/* Retrieves the number of milliseconds that have elapsed since the system was started */
	dwStart = GetTickCount();

	/* Let's sleep 1 minute so Sandbox is interested to patch that */
	Sleep(dwMillisecondsToSleep);

	/* Do it again */
	dwEnd = GetTickCount();

	/* If the Sleep function was patched*/
	dwDiff = dwEnd - dwStart;
	if (dwDiff > dwMillisecondsToSleep - 1000) // substracted 1s just to be sure
		return FALSE;
	else
		return TRUE;
}

/*
The CPUID instruction is a processor supplementary instruction (its name derived from
CPU IDentification) for the x86 architecture allowing software to discover details of
the processor. By calling CPUID with EAX =1, The 31bit of ECX register if set will
reveal the precense of a hypervisor.
*/
BOOL cpuid_is_hypervisor()
{
	INT CPUInfo[4] = { -1 };

	/* Query hypervisor precense using CPUID (EAX=1), BIT 31 in ECX */
	__cpuid(CPUInfo, 1);
	if ((CPUInfo[2] >> 31) & 1)
		return TRUE;
	else
		return FALSE;
}


/*
If HV presence confirmed then it is good to know which type of hypervisor we have
When CPUID is called with EAX=0x40000000, cpuid return the hypervisor signature.
*/
BOOL cpuid_hypervisor_vendor()
{
	INT CPUInfo[4] = { -1 };
	CHAR szHypervisorVendor[0x40];
	WCHAR *pwszConverted;

	BOOL bResult = FALSE;

	const TCHAR* szBlacklistedHypervisors[] = {
		_T("KVMKVMKVM\0\0\0"),	/* KVM */
		_T("Microsoft Hv"),		/* Microsoft Hyper-V or Windows Virtual PC */
		_T("VMwareVMware"),		/* VMware */
		_T("XenVMMXenVMM"),		/* Xen */
		_T("prl hyperv  "),		/* Parallels */
		_T("VBoxVBoxVBox"),		/* VirtualBox */
	};
	WORD dwlength = sizeof(szBlacklistedHypervisors) / sizeof(szBlacklistedHypervisors[0]);

	// __cpuid with an InfoType argument of 0 returns the number of
	// valid Ids in CPUInfo[0] and the CPU identification string in
	// the other three array elements. The CPU identification string is
	// not in linear order. The code below arranges the information 
	// in a human readable form.
	__cpuid(CPUInfo, 0x40000000);
	memset(szHypervisorVendor, 0, sizeof(szHypervisorVendor));
	memcpy(szHypervisorVendor, CPUInfo + 1, 12);

	for (int i = 0; i < dwlength; i++)
	{
		pwszConverted = ascii_to_wide_str(szHypervisorVendor);
		if (pwszConverted) {

			bResult = (_tcscmp(pwszConverted, szBlacklistedHypervisors[i]) == 0);

			free(pwszConverted);

			if (bResult)
				return TRUE;
		}
	}

	return FALSE;
}


/*
Check SerialNumber devices using WMI
*/
BOOL serial_number_bios_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_BIOS"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("SerialNumber"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					if (vtProp.vt == VT_BSTR) {

						// Do our comparison
						if (
							(StrStrI(vtProp.bstrVal, _T("VMWare")) != 0) ||
							(wcscmp(vtProp.bstrVal, _T("0")) == 0) || // VBox (serial is just "0")
							(StrStrI(vtProp.bstrVal, _T("Xen")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("Virtual")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("A M I")) != 0)
							)
						{
							VariantClear(&vtProp);
							pclsObj->Release();
							bFound = TRUE;
							break;
						}
					}
					VariantClear(&vtProp);
				}

				// release the current result object
				pclsObj->Release();
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}


/*
Check Model from ComputerSystem using WMI
*/
BOOL model_computer_system_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_ComputerSystem"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("Model"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					if (vtProp.vt == VT_BSTR) {

						// Do our comparison
						if (
							(StrStrI(vtProp.bstrVal, _T("VirtualBox")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("HVM domU")) != 0) || //Xen
							(StrStrI(vtProp.bstrVal, _T("VMWare")) != 0)
							)
						{
							VariantClear(&vtProp);
							pclsObj->Release();
							bFound = TRUE;
							break;
						}
					}
					VariantClear(&vtProp);
				}

				// release the current result object
				pclsObj->Release();
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}


/*
Check Manufacturer from ComputerSystem using WMI
*/
BOOL manufacturer_computer_system_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_ComputerSystem"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("Manufacturer"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					if (vtProp.vt == VT_BSTR) {

						// Do our comparison
						if (
							(StrStrI(vtProp.bstrVal, _T("VMWare")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("Xen")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("innotek GmbH")) != 0) || // Vbox
							(StrStrI(vtProp.bstrVal, _T("QEMU")) != 0)
							)
						{
							VariantClear(&vtProp);
							pclsObj->Release();
							bFound = TRUE;
							break;
						}
					}
					VariantClear(&vtProp);
				}
				// release the current result object
				pclsObj->Release();
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}


/*
Check Current Temperature using WMI, this requires admin privileges
In my tests, it works against vbox, vmware, kvm and xen.
*/
BOOL current_temperature_acpi_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// This technique required admin priviliege
	if (!IsElevated())
		return FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("root\\WMI"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM MSAcpi_ThermalZoneTemperature"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn) {
					bFound = TRUE;
					break;
				}

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("CurrentTemperature"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					VariantClear(&vtProp);
					pclsObj->Release();
					break;
				}

				// release the current result object
				VariantClear(&vtProp);
				pclsObj->Release();
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}

/*
Check ProcessId from Win32_Processor using WMI
KVM, XEN anv VMWare seems to return something, VBOX return NULL
*/
BOOL process_id_processor_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_Processor"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("ProcessorId"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {

					// Do our comparison
					if (vtProp.bstrVal == NULL)
					{
						bFound = TRUE;
					}
				}
				// release the current result object
				VariantClear(&vtProp);
				pclsObj->Release();

				// break from while
				if (bFound)
					break;
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}

/*
Check what power states are enabled.
Most VMs don't support S1-S4 power states whereas most hardware does, and thermal control is usually not found either.
This has been tested on VirtualBox and Hyper-V, as well as a physical desktop and laptop.
*/
BOOL power_capabilities()
{
	SYSTEM_POWER_CAPABILITIES powerCaps;
	BOOL bFound = FALSE;
	if (GetPwrCapabilities(&powerCaps) == TRUE)
	{
		if ((powerCaps.SystemS1 | powerCaps.SystemS2 | powerCaps.SystemS3 | powerCaps.SystemS4) == FALSE)
		{
			bFound = (powerCaps.ThermalControl == FALSE);
		}
	}

	return bFound;
}


/*
According to MSDN, this query should return a class that provides statistics on the CPU fan.
Win32/OilRig checks to see if the result of this query returned a class with more than 0 elements,
which would most likely be true in a non-virtual environment.
*/
BOOL cpu_fan_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;
	ULONG uObjCount = 0;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));
	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_Fan"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn) {
					break;
				}
				else {
					uObjCount++;
					pclsObj->Release();
				}
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	if (uObjCount == 0)
		bFound = TRUE;
	return bFound;
}


/*
Check Caption from VideoController using WMI
*/
BOOL caption_video_controller_wmi()
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;
	BOOL bFound = FALSE;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));

	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, _T("SELECT * FROM Win32_VideoController"));
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;
			VARIANT vtProp;

			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				// Get the value of the Name property
				hRes = pclsObj->Get(_T("Caption"), 0, &vtProp, 0, 0);
				if (SUCCEEDED(hRes)) {
					if (vtProp.vt == VT_BSTR) {

						// Do our comparison
						if (
							(StrStrI(vtProp.bstrVal, _T("Hyper-V")) != 0) ||
							(StrStrI(vtProp.bstrVal, _T("VMWare")) != 0)
							)
						{
							VariantClear(&vtProp);
							pclsObj->Release();
							bFound = TRUE;
							break;
						}
					}
					VariantClear(&vtProp);
				}

				// release the current result object
				pclsObj->Release();
			}

			// Cleanup
			pSvc->Release();
			pLoc->Release();
			pEnumerator->Release();
			CoUninitialize();
		}
	}

	return bFound;
}

/*
Detect Virtual machine by calling NtQueryLicenseValue with Kernel-VMDetection-Private as license value.
This detection works on Windows 7 and does not detect Microsoft Hypervisor.
*/
BOOL query_license_value()
{
	auto RtlInitUnicodeString = static_cast<pRtlInitUnicodeString>(API::GetAPI(API_IDENTIFIER::API_RtlInitUnicodeString));
	auto NtQueryLicenseValue = static_cast<pNtQueryLicenseValue>(API::GetAPI(API_IDENTIFIER::API_NtQueryLicenseValue));

	if (RtlInitUnicodeString == nullptr || NtQueryLicenseValue == nullptr)
		return FALSE;

	UNICODE_STRING LicenseValue;
	RtlInitUnicodeString(&LicenseValue, L"Kernel-VMDetection-Private");

	ULONG Result = 0, ReturnLength;

	NTSTATUS Status = NtQueryLicenseValue(&LicenseValue, NULL, reinterpret_cast<PVOID>(&Result), sizeof(ULONG), &ReturnLength);

	if (NT_SUCCESS(Status)) {
		return (Result != 0);
	}

	return FALSE;
}

int wmi_query_count(const _TCHAR* query)
{
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	BOOL bStatus = FALSE;
	HRESULT hRes;

	int count = 0;

	// Init WMI
	bStatus = InitWMI(&pSvc, &pLoc, _T("ROOT\\CIMV2"));
	if (bStatus)
	{
		// If success, execute the desired query
		bStatus = ExecWMIQuery(&pSvc, &pLoc, &pEnumerator, query);
		if (bStatus)
		{
			// Get the data from the query
			IWbemClassObject *pclsObj = NULL;
			ULONG uReturn = 0;

			// Iterate over our enumator
			while (pEnumerator)
			{
				hRes = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
				if (0 == uReturn)
					break;

				count++;

				pclsObj->Release();
			}

			// Cleanup
			pEnumerator->Release();
			pSvc->Release();
			pLoc->Release();
			CoUninitialize();
		}
		else
		{
			pSvc->Release();
			pLoc->Release();
			CoUninitialize();
		}
	}
	else return -1;

	return count;
}

/*
Check Win32_CacheMemory for entries
*/
BOOL cachememory_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_CacheMemory"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_PhysicalMemory for entries
*/
BOOL physicalmemory_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_PhysicalMemory"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_MemoryDevice for entries
*/
BOOL memorydevice_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_MemoryDevice"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_MemoryArray for entries
*/
BOOL memoryarray_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_MemoryArray"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_VoltageProbe for entries
*/
BOOL voltageprobe_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_VoltageProbe"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_PortConnector for entries
*/
BOOL portconnector_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_PortConnector"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_SMBIOSMemory for entries
*/
BOOL smbiosmemory_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_SMBIOSMemory"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check Win32_PerfFormattedData_Counters_ThermalZoneInformation for entries
*/
BOOL perfctrs_thermalzoneinfo_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_Memory for entries
*/
BOOL cim_memory_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_Memory"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_NumericSensor for entries
*/
BOOL cim_numericsensor_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_NumericSensor"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_PhysicalConnector for entries
*/
BOOL cim_physicalconnector_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_PhysicalConnector"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_Sensor for entries
*/
BOOL cim_sensor_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_Sensor"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_Slot for entries
*/
BOOL cim_slot_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_Slot"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_TemperatureSensor for entries
*/
BOOL cim_temperaturesensor_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_TemperatureSensor"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check CIM_VoltageSensor for entries
*/
BOOL cim_voltagesensor_wmi()
{
	int count = wmi_query_count(_T("SELECT * FROM CIM_VoltageSensor"));
	if (count == 0)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Checks whether the specified application is a genuine Windows installation.

*/

#define WINDOWS_SLID                                                \
            { 0x55c92734,                                           \
              0xd682,                                               \
              0x4d71,                                               \
              { 0x98, 0x3e, 0xd6, 0xec, 0x3f, 0x16, 0x05, 0x9f }    \
            }

BOOL pirated_windows()
{
	CONST SLID AppId = WINDOWS_SLID;
	SL_GENUINE_STATE GenuineState;
	HRESULT hResult;

	hResult = SLIsGenuineLocal(&AppId, &GenuineState, NULL);

	if (hResult == S_OK) {
		if (GenuineState != SL_GEN_STATE_IS_GENUINE) {
			return TRUE;
		}
	}
	return FALSE;
}

/* Check HKLM\System\CurrentControlSet\Services\Disk\Enum for values related
 * to virtual machines. */
BOOL registry_services_disk_enum()
{
	HKEY hkResult = NULL;
	const TCHAR* diskEnumKey = _T("System\\CurrentControlSet\\Services\\Disk\\Enum");
	DWORD diskCount = 0;
	DWORD cbData = sizeof(diskCount);
	const TCHAR* szChecks[] = {
		/* Checked for by Smokeloader
		 * https://research.checkpoint.com/2019-resurgence-of-smokeloader/*/
		 _T("qemu"),
		 _T("virtio"),
		 _T("vmware"),
		 _T("vbox"),
		 _T("xen"),

		 /* Checked for by Kutaki (not including ones from above)
		 * https://cofense.com/kutaki-malware-bypasses-gateways-steal-users-credentials/ */
		_T("VMW"),
		_T("Virtual"),

	};
	WORD dwChecksLength = sizeof(szChecks) / sizeof(szChecks[0]);
	BOOL bFound = FALSE;

	/* Each disk has a corresponding value where the value name starts at '0' for
	 * the first disk and increases by 1 for each subsequent disk.  The 'Count'
	 * value appears to store the total number of disk entries.*/

	if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, diskEnumKey, NULL, KEY_READ, &hkResult) == ERROR_SUCCESS)
	{
		if (RegQueryValueEx(hkResult, _T("Count"), NULL, NULL, (LPBYTE)&diskCount, &cbData) != ERROR_SUCCESS)
		{
			RegCloseKey(hkResult);
			return bFound;
		}
		RegCloseKey(hkResult);
	}

	for (unsigned int i = 0; i < diskCount; i++) {
		TCHAR subkey[11];

		_stprintf_s(subkey, sizeof(subkey) / sizeof(subkey[0]), _T("%d"), i);

		for (unsigned int j = 0; j < dwChecksLength; j++) {
			//_tprintf(_T("Checking %s %s for %s (%d)\n"), diskEnumKey, subkey, szChecks[j], diskCount);
			if (Is_RegKeyValueExists(HKEY_LOCAL_MACHINE, diskEnumKey, subkey, szChecks[j])) {
				bFound = TRUE;
				break;
			}
		}
		if (bFound) {
			break;
		}
	}
	return bFound;
}

BOOL registry_disk_enum()
{
	HKEY hkResult = NULL;
	const TCHAR* szEntries[] = {
		_T("System\\CurrentControlSet\\Enum\\IDE"),
		_T("System\\CurrentControlSet\\Enum\\SCSI"),
	};
	const TCHAR* szChecks[] = {
		/* Checked for by Smokeloader
		 * https://research.checkpoint.com/2019-resurgence-of-smokeloader/*/
		 _T("qemu"),
		 _T("virtio"),
		 _T("vmware"),
		 _T("vbox"),
		 _T("xen"),

		 /* Checked for by Kutaki (not including ones from above)
		 * https://cofense.com/kutaki-malware-bypasses-gateways-steal-users-credentials/ */
		_T("VMW"),
		_T("Virtual"),

	};
	WORD dwEntriesLength = sizeof(szEntries) / sizeof(szEntries[0]);
	WORD dwChecksLength = sizeof(szChecks) / sizeof(szChecks[0]);
	BOOL bFound = FALSE;

	for (unsigned int i = 0; i < dwEntriesLength; i++) {
		DWORD cSubKeys = 0;
		DWORD cbMaxSubKeyLen = 0;
		if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, szEntries[i], NULL, KEY_READ, &hkResult) != ERROR_SUCCESS) {
			continue;
		}

		if (RegQueryInfoKey(hkResult, NULL, NULL, NULL, &cSubKeys, &cbMaxSubKeyLen, NULL, NULL, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
			RegCloseKey(hkResult);
			continue;
		}

		DWORD subKeyBufferLen = (cbMaxSubKeyLen + 1) * sizeof(TCHAR);
		TCHAR* subKeyBuffer = (TCHAR *)malloc(subKeyBufferLen);
		if (!subKeyBuffer) {
			RegCloseKey(hkResult);
			continue;
		}

		for (unsigned int j = 0; j < cSubKeys; j++) {
			DWORD cchName = subKeyBufferLen;
			if (RegEnumKeyEx(hkResult, j, subKeyBuffer, &cchName, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
				continue;
			}
			for (unsigned int k = 0; k < dwChecksLength; k++) {
				//_tprintf(_T("Checking %s %s for %s (%d)\n"), szEntries[i], subKeyBuffer, szChecks[k], cSubKeys);
				if (StrStrI(subKeyBuffer, szChecks[k]) != NULL) {
					bFound = TRUE;
					break;
				}
			}
			if (bFound) {
				break;
			}
		}

		free(subKeyBuffer);
		RegCloseKey(hkResult);

		if (bFound) {
			break;
		}
	}
	return bFound;
}

BOOL handle_one_table(BYTE* currentPosition, UINT& bias, BYTE* smBiosTableBoundary)
{
	struct SmbiosTableHeader
	{
		BYTE type;       // Table type
		BYTE length;     // Length of the table
		WORD handle;     // Handle of the table
	};

	SmbiosTableHeader* tableHeader = reinterpret_cast<SmbiosTableHeader*>(currentPosition);
	SmbiosTableHeader* tableBoundary = reinterpret_cast<SmbiosTableHeader*>(smBiosTableBoundary);

	const BYTE lastEntry = 127;
	if (tableHeader->type == lastEntry) {
		// End of tables reached
		return TRUE;
	}

	currentPosition += tableHeader->length;
	UINT i = 0;
	// Find the end of the table
	while (!(currentPosition[i] == 0 && currentPosition[i + 1] == 0)
		&& (currentPosition + i + 1 < smBiosTableBoundary))
	{
		i++;
	}
	//pair of terminal zeros
	i += 2;
	bias = i + tableHeader->length;

	return FALSE;
}

BOOL check_tables_number(const PBYTE smbios)
{
	struct RawSMBIOSData
	{
		BYTE    method;           // Access method(obsolete)
		BYTE    mjVer;            // Major part of the SMB version(major)
		BYTE    mnVer;            // Minor part of the SMB version(minor)
		BYTE    dmiRev;           // DMI version(obsolete)
		DWORD   length;           // Data table size
		BYTE    tableData[];      // Table data
	};

	RawSMBIOSData* smBiosData = reinterpret_cast<RawSMBIOSData*>(smbios);
	BYTE* smBiosTableBoundary = smBiosData->tableData + smBiosData->length;
	BYTE* currentPosition = smBiosData->tableData;
	UINT tableNumber = 0;

	while (currentPosition < smBiosTableBoundary) {
		UINT biasNewTable = 0;
		tableNumber++;
		if (handle_one_table(currentPosition, biasNewTable, smBiosTableBoundary))
		{
			break;
		}
		currentPosition += biasNewTable;
	}

	const UINT tableMinReal = 40;
	if (tableNumber <= tableMinReal)
	{
		return TRUE;
	}
	return FALSE;
}

/*
Check for SMBIOS tables number
*/
BOOL number_SMBIOS_tables()
{
	BOOL result = FALSE;

	DWORD smbiosSize = 0;
	PBYTE smbios = get_system_firmware(static_cast<DWORD>('RSMB'), 0x0000, &smbiosSize);
	if (smbios != NULL)
	{
		result = check_tables_number(smbios);
		free(smbios);
	}
	return result;
}
