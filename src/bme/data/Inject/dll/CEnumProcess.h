#pragma once
#include "afxcmn.h"
#include "Common.h"



typedef struct _PROCESS_INFORMATION_ENTRY_
{
	char ProcessName[50];
	ULONG Pid;
	ULONG ParentId;
	WCHAR ProcessPath[260];
	ULONG_PTR Eprocess;
	BOOLEAN IsAccess;
	WCHAR Company[20];
}PROCESS_INFORMATION_ENTRY, *PPROCESS_INFORMATION_ENTRY;
typedef struct _PROCESS_INFORMATION_OWN
{
	ULONG_PTR    NumberOfEntry;
	PROCESS_INFORMATION_ENTRY Entry[1];
}PROCESS_INFORMATION_OWN, *PPROCESS_INFORMATION_OWN;


class CEnumProcess : public CDialogEx
{
	DECLARE_DYNAMIC(CEnumProcess)

public:
	CEnumProcess(CWnd* pParent = NULL);   // ��׼���캯��
	virtual ~CEnumProcess();
	PPROCESS_INFORMATION_OWN ProcessInformation;
	VOID CEnumProcess::EnumProcess(ULONG_PTR Code);
	VOID AddItemToControlList(PPROCESS_INFORMATION_OWN ProcessInformation);
// �Ի�������
	enum { IDD = IDD_DIALOG_ENUMPROCESS };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnBnClickedButtonPspcidtable();
	afx_msg void OnBnClickedButtonActiveprocesslinks();
	afx_msg void OnBnClickedButtonOpenprocess();
	CListCtrl m_List_EnumProcess;
	virtual BOOL OnInitDialog();
	afx_msg void OnRclickListProcess(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnMenuHide();
};



