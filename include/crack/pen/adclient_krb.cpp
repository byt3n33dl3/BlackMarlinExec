/*
 * ----------------------------------------------------------------------------
 * Author: Markus Moeller (markus_moeller at compuserve.com)
 * -----------------------------------------------------------------------------
 */

#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <krb5.h>
#include <iostream>

#include "adclient.h"

using std::cout;
using std::endl;

#define KT_PATH_MAX 256
#define safe_free(x)    while ((x)) { free((x)); (x) = NULL; }

void
krb5_cleanup(krb_struct &krb_param)
{
    if (krb_param.context) {
        if (krb_param.cc) {
            krb5_cc_destroy(krb_param.context, krb_param.cc);
        }
        krb5_free_context(krb_param.context);
    }
}
/*
 * create Kerberos memory cache
 */
int
krb5_create_cache(const char *domain)
{
    krb_struct krb_param;
    krb_param.context = NULL;
    krb_param.cc = NULL;

    krb5_keytab keytab = 0;
    krb5_keytab_entry entry;
    krb5_kt_cursor cursor;
    krb5_creds *creds = NULL;
    krb5_principal *principal_list = NULL;
    krb5_principal principal = NULL;
    char *service;
    char *keytab_name = NULL, *principal_name = NULL, *mem_cache = NULL;
    char buf[KT_PATH_MAX], *p;
    size_t j,nprinc = 0;
    int retval = 0;
    krb5_error_code code = 0;

    if (!domain || !strcmp(domain, ""))
        return (1);

    /*
     * Initialise Kerberos
     */

    code = krb5_init_context(&krb_param.context);
    if (code) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "%s| %s: ERROR: Error while initialising Kerberos library: " << s << endl;
        retval = 1;
        goto cleanup;
    }
    /*
     * getting default keytab name
     */

    //cout << "DEBUG: Get default keytab file name" << endl;
    krb5_kt_default_name(krb_param.context, buf, KT_PATH_MAX);
    p = strchr(buf, ':'); /* Find the end if "FILE:" */
    if (p)
        ++p;            /* step past : */
    keytab_name = strdup(p ? p : buf);
    //cout << "DEBUG: Got default keytab file name " << keytab_name << endl;

    code = krb5_kt_resolve(krb_param.context, keytab_name, &keytab);
    if (code) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "ERROR: Error while resolving keytab " << keytab_name << ": " << s << endl;
        retval = 1;
        goto cleanup;
    }
    code = krb5_kt_start_seq_get(krb_param.context, keytab, &cursor);
    if (code) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "ERROR: Error while starting keytab scan: " << s << endl;
        retval = 1;
        goto cleanup;
    }
    //cout << "DEBUG: Get principal name from keytab" << keytab_name << endl;

    nprinc = 0;
    while ((code = krb5_kt_next_entry(krb_param.context, keytab, &entry, &cursor)) == 0) {
        int found = 0;

        krb5_principal *new_principal_list;
        new_principal_list = (krb5_principal *) realloc(principal_list, sizeof(krb5_principal) * (nprinc + 1));
        if (!new_principal_list) {
            retval = 1;
            goto cleanup;
        } else {
            principal_list = new_principal_list;
        }
        krb5_copy_principal(krb_param.context, entry.principal, &principal_list[nprinc++]);
        //cout << "DEBUG: Keytab entry has realm name: " << krb5_princ_realm(krb_param.context, entry.principal)->data << endl;
        if (!strcasecmp(domain, krb5_princ_realm(krb_param.context, entry.principal)->data))
        {
            code = krb5_unparse_name(krb_param.context, entry.principal, &principal_name);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "ERROR: Error while unparsing principal name:" << s << endl;
            } else {
                //cout << "DEBUG: Found principal name:" << principal_name << endl;
                found = 1;
            }
        }
        code = krb5_free_keytab_entry_contents(krb_param.context, &entry);
        if (code) {
            //const char *s = krb5_get_error_message(krb_param.context, code);
            //cout << "ERROR: Error while freeing keytab entry: " << s << endl;
            retval = 1;
            break;
        }
        if (found)
            break;
    }

    if (code && code != KRB5_KT_END) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "ERROR: Error while scanning keytab: " << s << endl;
        retval = 1;
        goto cleanup;
    }
    code = krb5_kt_end_seq_get(krb_param.context, keytab, &cursor);
    if (code) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "ERROR: Error while ending keytab scan: " << s << endl;
        retval = 1;
        goto cleanup;
    }
    /*
     * prepare memory credential cache
     */
#if  !defined(HAVE_KRB5_MEMORY_CACHE) || defined(HAVE_SUN_LDAP_SDK)
    mem_cache = (char *) malloc(strlen("FILE:/tmp/libadclient_") + 16);
    snprintf(mem_cache, strlen("FILE:/tmp/libadclient_") + 16, "FILE:/tmp/libadclient_%d", (int) getpid());
#else
    mem_cache = (char *) malloc(strlen("MEMORY:libadclient_") + 16);
    snprintf(mem_cache, strlen("MEMORY:libadclient_") + 16, "MEMORY:libadclient_%d", (int) getpid());
#endif

    if (!mem_cache) {
        retval = 1;
        goto cleanup;
    }

    setenv("KRB5CCNAME", mem_cache, 1);
    //cout << "DEBUG: Set credential cache to " << mem_cache << endl;
    code = krb5_cc_resolve(krb_param.context, mem_cache, &krb_param.cc);
    if (code) {
        //const char *s = krb5_get_error_message(krb_param.context, code);
        //cout << "ERROR: Error while resolving memory ccache: " << s << endl;
        retval = 1;
        goto cleanup;
    }
    /*
     * if no principal name found in keytab for domain use the prinipal name which can get a TGT
     */
    if (!principal_name) {
        size_t i;
        //cout << "DEBUG: Did not find a principal in keytab for domain " << domain << endl;
        //cout << "DEBUG: Try to get principal of trusted domain" << endl;

        for (i = 0; i < nprinc; ++i) {
            krb5_creds *tgt_creds = NULL;
            creds = (krb5_creds *) malloc(sizeof(*creds));
            if (!creds) {
                retval = 1;
                goto cleanup;
            }
            memset(creds, 0, sizeof(*creds));
            /*
             * get credentials
             */
            code = krb5_unparse_name(krb_param.context, principal_list[i], &principal_name);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "DEBUG: Error while unparsing principal name: " << s << endl;
                goto loop_end;
            }
            //cout << "DEBUG: Keytab entry has principal: " << principal_name << endl;

            code = krb5_get_init_creds_keytab(krb_param.context, creds, principal_list[i], keytab, 0, NULL, NULL);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "DEBUG: Error while initialising credentials from keytab: " << s << endl;
                goto loop_end;
            }
            code = krb5_cc_initialize(krb_param.context, krb_param.cc, principal_list[i]);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "ERROR: Error while initializing memory caches: " << s << endl;
                goto loop_end;
            }
            code = krb5_cc_store_cred(krb_param.context, krb_param.cc, creds);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "DEBUG: Error while storing credentials: " << s << endl;
                goto loop_end;
            }
            if (creds->server)
                krb5_free_principal(krb_param.context, creds->server);
            service = (char *) malloc(strlen("krbtgt") + strlen(domain) + strlen(krb5_princ_realm(krb_param.context, principal_list[i])->data) + 3);
            snprintf(service, strlen("krbtgt") + strlen(domain) + strlen(krb5_princ_realm(krb_param.context, principal_list[i])->data) + 3, "krbtgt/%s@%s", domain, krb5_princ_realm(krb_param.context, principal_list[i])->data);
            code = krb5_parse_name(krb_param.context, service, &creds->server);
            free(service);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "ERROR: Error while initialising TGT credentials: " << s << endl;
                goto loop_end;
            }
            code = krb5_get_credentials(krb_param.context, 0, krb_param.cc, creds, &tgt_creds);
            if (code) {
                //const char *s = krb5_get_error_message(krb_param.context, code);
                //cout << "DEBUG: Error while getting tgt: " << s << endl;
                goto loop_end;
            } else {
                //cout << "DEBUG: Found trusted principal name: " << principal_name << endl;
                break;
            }

loop_end:
            safe_free(principal_name);
            if (tgt_creds) {
                krb5_free_creds(krb_param.context, tgt_creds);
                tgt_creds = NULL;
            }
            krb5_free_creds(krb_param.context, creds);
            creds = NULL;

        }

        if (creds)
            krb5_free_creds(krb_param.context, creds);
        creds = NULL;
    }
    if (principal_name) {
        //cout << "DEBUG: Got principal name " << principal_name << endl;
        /*
         * build principal
         */
        code = krb5_parse_name(krb_param.context, principal_name, &principal);
        if (code) {
            //const char *s = krb5_get_error_message(krb_param.context, code);
            //cout << "ERROR: Error while parsing name " << principal_name << ": " << s << endl;
            retval = 1;
            goto cleanup;
        }
        creds = (krb5_creds *) malloc(sizeof(*creds));
        if (!creds) {
            retval = 1;
            goto cleanup;
        }
        memset(creds, 0, sizeof(*creds));

        /*
         * get credentials
         */
        code = krb5_get_init_creds_keytab(krb_param.context, creds, principal, keytab, 0, NULL, NULL);
        if (code) {
            //const char *s = krb5_get_error_message(krb_param.context, code);
            //cout << "ERROR: Error while initialising credentials from keytab: " << s << endl;
            retval = 1;
            goto cleanup;
        }
        code = krb5_cc_initialize(krb_param.context, krb_param.cc, principal);
        if (code) {
            //const char *s = krb5_get_error_message(krb_param.context, code);
            //cout << "ERROR: Error while initializing memory caches: " << s << endl;
            retval = 1;
            goto cleanup;
        }
        code = krb5_cc_store_cred(krb_param.context, krb_param.cc, creds);
        if (code) {
            //const char *s = krb5_get_error_message(krb_param.context, code);
            //cout << "ERROR: Error while storing credentials: " << s << endl;
            retval = 1;
            goto cleanup;
        }
        //cout << "DEBUG: Stored credentials" << endl;
    } else {
        //cout << "DEBUG: Got no principal name" << endl;
        retval = 1;
    }
cleanup:
    if (keytab)
        krb5_kt_close(krb_param.context, keytab);
    free(keytab_name);
    free(principal_name);
    free(mem_cache);
    if (principal)
        krb5_free_principal(krb_param.context, principal);
    for (j = 0; j < nprinc; ++j) {
        if (principal_list[j])
            krb5_free_principal(krb_param.context, principal_list[j]);
    }
    free(principal_list);
    if (creds)
        krb5_free_creds(krb_param.context, creds);

    krb5_cleanup(krb_param);
    return (retval);
}
