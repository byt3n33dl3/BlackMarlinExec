#pragma once
#include "afxwin.h"
#include "resource.h"

// MonitorProcess �Ի���

class MonitorProcess : public CDialogEx
{
	DECLARE_DYNAMIC(MonitorProcess)

public:
	MonitorProcess(CWnd* pParent = NULL);   // ��׼���캯��
	virtual ~MonitorProcess();
		ULONG   m_ulCount;
// �Ի�������
	enum { IDD = IDD_DIALOG_MESSAGE };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

	DECLARE_MESSAGE_MAP()
public:
	CEdit m_EditControl;
	afx_msg void OnBnClickedButtonDeny();
	afx_msg void OnBnClickedButtonAccept();
	virtual BOOL OnInitDialog();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
};
