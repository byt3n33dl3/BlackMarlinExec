#include "stdlib.h"
#include "adclient.h"

/*
  Active Directory class.

  adclient::login can throw ADBindException on errors.
  all search functions can throw ADSearchException on errors.
  all modify functions can throw both ADSearchException and ADOperationalException on errors.
   text description will be in 'msg' property
   numeric code in 'code' property
*/

adclient::adclient() {
/*
  Constructor, to initialize default values of global variables.
*/
    ds = NULL;
}

adclient::~adclient() {
/*
  Destructor, to automaticaly free initial values allocated at login().
*/
    logout(ds);
}

void adclient::logout(LDAP *ds) {
    if (ds != NULL) {
        ldap_unbind_ext(ds, NULL, NULL);
    }
}

void adclient::login(adConnParams _params) {
    ldap_prefix = _params.use_ldaps ? "ldaps" : "ldap";

    if (!_params.uries.empty()) {
        for (vector <string>::iterator it = _params.uries.begin(); it != _params.uries.end(); ++it) {
            if (it->find("://") == string::npos) {
                _params.uri = ldap_prefix + "://" + *it;
            } else {
                _params.uri = *it;
            }
            try {
                login(&ds, _params);
                params = _params;
                return;
            }
            catch (ADBindException&) {
                if (ds != NULL) {
                    ldap_unbind_ext(ds, NULL, NULL);
                    ds = NULL;
                }

                if (it != (_params.uries.end() - 1)) {
                    continue;
                } else {
                    throw;
                }
            }
        }
        throw ADBindException("No suitable connection uries found", AD_PARAMS_ERROR);
    } else if (!_params.domain.empty()) {
        if (_params.search_base.empty()) {
            _params.search_base = domain2dn(_params.domain);
        }
        _params.uries = get_ldap_servers(_params.domain, _params.site);
        login(_params);
    } else {
        throw ADBindException("No suitable connection params found", AD_PARAMS_ERROR);
    }
}

void adclient::login(vector <string> uries, string binddn, string bindpw, string search_base, bool secured) {
/*
  Wrapper around login to support list of uries
*/
    adConnParams _params;
    _params.uries = uries;
    _params.binddn = binddn;
    _params.bindpw = bindpw;
    _params.search_base = search_base;
    _params.secured = secured;
    login(_params);
}

void adclient::login(string _uri, string binddn, string bindpw, string search_base, bool secured) {
/*
  Wrapper around login to fill LDAP* structure
*/
    adConnParams _params;
    _params.uries.push_back(_uri);
    _params.binddn = binddn;
    _params.bindpw = bindpw;
    _params.search_base = search_base;
    _params.secured = secured;
    login(_params);
}

void adclient::login(LDAP **ds, adConnParams& _params) {
/*
  To set various LDAP options and bind to LDAP server.
  It set private pointer to LDAP connection identifier - ds.
  It returns nothing if operation was successfull, throws ADBindException otherwise.
*/
    logout(*ds);

    int result, version, bindresult = -1;

    string error_msg;

    if (_params.use_ldaps && _params.use_tls) {
        error_msg = "Error in passed params: use_ldaps and use_tls are mutually exclusive";
        throw ADBindException(error_msg, AD_PARAMS_ERROR);
    }

#if defined OPENLDAP
    result = ldap_initialize(ds, _params.uri.c_str());
#elif defined SUNLDAP
    result = ldapssl_init(_params.uri.c_str(), LDAPS_PORT, 1);
#else
#error LDAP library required
#endif
    if (result != LDAP_SUCCESS) {
        error_msg = "Error in ldap_initialize to " + _params.uri + ": ";
        error_msg.append(ldap_err2string(result));
        throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
    }

    if (_params.nettimeout != -1) {
        struct timeval optTimeout;
        optTimeout.tv_usec = 0;
        optTimeout.tv_sec = _params.nettimeout;

        result = ldap_set_option(*ds, LDAP_OPT_TIMEOUT, &optTimeout);
        if (result != LDAP_OPT_SUCCESS) {
            error_msg = "Error in ldap_set_option (general timeout): ";
            error_msg.append(ldap_err2string(result));
            throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
        }

        result = ldap_set_option(*ds, LDAP_OPT_NETWORK_TIMEOUT, &optTimeout);
        if (result != LDAP_OPT_SUCCESS) {
            error_msg = "Error in ldap_set_option (network timeout): ";
            error_msg.append(ldap_err2string(result));
            throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
        }
    }

    if (_params.timelimit != -1) {
        result = ldap_set_option(*ds, LDAP_OPT_TIMELIMIT, &_params.timelimit);
        if (result != LDAP_OPT_SUCCESS) {
            error_msg = "Error in ldap_set_option (time limit): ";
            error_msg.append(ldap_err2string(result));
            throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
        }
    }

    version = LDAP_VERSION3;
    result = ldap_set_option(*ds, LDAP_OPT_PROTOCOL_VERSION, &version);
    if (result != LDAP_OPT_SUCCESS) {
        error_msg = "Error in ldap_set_option (protocol->v3): ";
        error_msg.append(ldap_err2string(result));
        throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
    }

    result = ldap_set_option(*ds, LDAP_OPT_REFERRALS, LDAP_OPT_OFF);
    if (result != LDAP_OPT_SUCCESS) {
        error_msg = "Error in ldap_set_option (referrals->off): ";
        error_msg.append(ldap_err2string(result));
        throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
    }

    if (_params.use_tls) {
        result = ldap_start_tls_s(*ds, NULL, NULL);
        if (result != LDAP_SUCCESS) {
            error_msg = "Error in ldap_start_tls_s: ";
            error_msg.append(ldap_err2string(result));
            throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
        }
        _params.bind_method = "StartTLS";
    } else {
        _params.bind_method = _params.use_ldaps ? "LDAPS" : "plain";
    }

    if (_params.secured) {
#ifdef KRB5
        if (_params.use_gssapi) {
            if (krb5_create_cache(_params.domain.c_str()) == 0) {
                _params.login_method = "GSSAPI";
                bindresult = sasl_bind_gssapi(*ds);
                if (bindresult == LDAP_SUCCESS) {
                    ldap_set_rebind_proc(*ds, sasl_rebind_gssapi, NULL);
                }
            } else {
                bindresult = -1;
            }
        } else {
#endif
            _params.login_method = "DIGEST-MD5";
            bindresult = sasl_bind_digest_md5(*ds, _params.binddn, _params.bindpw);
#ifdef KRB5
        }
#endif
    } else {
        _params.login_method = "SIMPLE";
        bindresult = sasl_bind_simple(*ds, _params.binddn, _params.bindpw);
    }

    if (bindresult != LDAP_SUCCESS) {
        error_msg = "Error while " + _params.login_method + " ldap binding to " + _params.uri + ": ";
        error_msg.append(ldap_err2string(bindresult));
        throw ADBindException(error_msg, AD_SERVER_CONNECT_FAILURE);
    }
}

bool adclient::checkUserPassword(string user, string password) {
/*
  It returns true of false depends on user credentials correctness.
*/
    LDAP *ld = NULL;

    bool result = true;
    try {
        adConnParams _params(params);
        _params.binddn = user;
        _params.bindpw = password;
        _params.use_gssapi = false;
        login(&ld, _params);
    }
    catch (ADBindException& ex) {
        result = false;
    }
    logout(ld);
    return result;
}

map < string, map < string, vector<string> > > adclient::search(string OU, int scope, string filter, const vector <string> &attributes) {
/*
  General search function.
  It returns map with users found with 'filter' with specified 'attributes'.
*/

    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    int result, errcodep;

    char *attrs[50];
    int attrsonly = 0;

    string error_msg = "";

    ber_int_t       pagesize = 1000;
    ber_int_t       totalcount;
    struct berval   *cookie = NULL;
    int             iscritical = 1;

    LDAPControl     *serverctrls[2] = { NULL, NULL };
    LDAPControl     *pagecontrol = NULL;
    LDAPControl     **returnedctrls = NULL;

    LDAPMessage *res = NULL;
    LDAPMessage *entry;

    char *dn;

    bool morepages;

    map < string, map < string, vector<string> > > search_result;

    if (attributes.size() > 50) throw ADSearchException("Cant return more than 50 attributes", AD_PARAMS_ERROR);

    unsigned int i;
    for (i = 0; i < attributes.size(); ++i) {
        attrs[i] = strdup(attributes[i].c_str());
    }
    attrs[i] = NULL;

    replace(filter, "\\", "\\\\");

    do {
        result = ldap_create_page_control(ds, pagesize, cookie, iscritical, &pagecontrol);
        if (result != LDAP_SUCCESS) {
            error_msg = "Failed to create page control: ";
            error_msg.append(ldap_err2string(result));
            break;
        }
        serverctrls[0] = pagecontrol;

        /* Search for entries in the directory using the parmeters.       */
        result = ldap_search_ext_s(ds, OU.c_str(), scope, filter.c_str(), attrs, attrsonly, serverctrls, NULL, NULL, LDAP_NO_LIMIT, &res);
        if ((result != LDAP_SUCCESS) & (result != LDAP_PARTIAL_RESULTS)) {
            error_msg = "Error in paged ldap_search_ext_s: ";
            error_msg.append(ldap_err2string(result));
            break;
        }
        serverctrls[0] = NULL;
        ldap_control_free(pagecontrol);
        pagecontrol = NULL;

        int num_results = ldap_count_entries(ds, res);
        if (num_results == 0) {
            error_msg = filter + " not found";
            result = AD_OBJECT_NOT_FOUND;
            break;
        }

        map < string, vector<string> > valuesmap;

        for ( entry = ldap_first_entry(ds, res);
              entry != NULL;
              entry = ldap_next_entry(ds, entry) ) {
            dn = ldap_get_dn(ds, entry);
            valuesmap = _getvalues(entry);
            search_result[dn] = valuesmap;
            ldap_memfree(dn);
        }

        /* Parse the results to retrieve the contols being returned.      */
        result = ldap_parse_result(ds, res, &errcodep, NULL, NULL, NULL, &returnedctrls, false);
        if (result != LDAP_SUCCESS) {
            error_msg = "Failed to parse result: ";
            error_msg.append(ldap_err2string(result));
            break;
        }

        /* Parse the page control returned to get the cookie and          */
        /* determine whether there are more pages.                        */
        pagecontrol = ldap_control_find(LDAP_CONTROL_PAGEDRESULTS, returnedctrls, NULL);
        if (pagecontrol == NULL) {
            error_msg = "Failed to find PAGEDRESULTS control";
            result = 255;
            break;
        }

        struct berval newcookie;
        result = ldap_parse_pageresponse_control(ds, pagecontrol, &totalcount, &newcookie);
        if (result != LDAP_SUCCESS) {
            error_msg = "Failed to parse pageresponse control: ";
            error_msg.append(ldap_err2string(result));
            break;
        }
        ber_bvfree(cookie);
        cookie = reinterpret_cast<berval*>(ber_memalloc( sizeof( struct berval ) ));
        if (cookie == NULL) {
            error_msg = "Failed to allocate memory for cookie";
            result = 255;
            break;
        }
        *cookie = newcookie;

        /* Cleanup the controls used. */
        ldap_controls_free(returnedctrls);
        returnedctrls = NULL;

        /* Determine if the cookie is not empty, indicating there are more pages for these search parameters. */
        if (cookie->bv_val != NULL && (strlen(cookie->bv_val) > 0)) {
            morepages = true;
        } else {
            morepages = false;
        }

        ldap_msgfree(res);
    } while (morepages);

    for (i = 0; i < attributes.size(); ++i) {
        free(attrs[i]);
    }

    if (cookie != NULL) {
        ber_bvfree(cookie);
    }

    if (error_msg.empty()) {
        return search_result;
    } else {
        ldap_msgfree(res);
        throw ADSearchException(error_msg, result);
    }
}

bool adclient::ifDNExists(string dn) {
/*
  Wrapper around two arguments ifDNExists for searching any objectclass DN
*/
    return ifDNExists(dn, "*");
}

bool adclient::ifDNExists(string dn, string objectclass) {
/*
  It returns true of false depends on object DN existence.
*/
    int result;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    char *attrs[] = {"1.1", NULL};
#pragma GCC diagnostic pop
    LDAPMessage *res;
    string error_msg;
    int attrsonly = 1;

    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string filter = "(objectclass=" + objectclass + ")";
    result = ldap_search_ext_s(ds, dn.c_str(), LDAP_SCOPE_SUBTREE, filter.c_str(), attrs, attrsonly, NULL, NULL, NULL, LDAP_NO_LIMIT, &res);
    ldap_msgfree(res);

    return (result == LDAP_SUCCESS);
}

vector <string> adclient::searchDN(string search_base, string filter, int scope) {
/*
  It returns vector with DNs found with 'filter'.
*/
    map < string, map < string, vector<string> > > search_result;

    vector <string> attributes;
    attributes.push_back("1.1");

    search_result = search(search_base.c_str(), scope, filter, attributes);

    vector <string> result;

    map < string, map < string, vector<string> > >::iterator res_it;
    for ( res_it=search_result.begin() ; res_it != search_result.end(); ++res_it ) {
        string dn = (*res_it).first;
        result.push_back(dn);
    }

    return result;
}

string adclient::getObjectDN(string object) {
/*
  It returns user DN by short name.
*/
    if (ifDNExists(object)) {
        return object;
    } else {
        replace(object, "(", "\\(");
        replace(object, ")", "\\)");
        vector <string> dn = searchDN(params.search_base, "(sAMAccountName=" + object + ")", LDAP_SCOPE_SUBTREE);
        return dn[0];
    }
}

void adclient::mod_add(string object, string attribute, string value) {
/*
  It performs generic LDAP_MOD_ADD operation on object (short_name/DN).
  It adds value to attribute.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(object);

    LDAPMod *attrs[2];
    LDAPMod attr;
    char *values[2];
    int result;
    string error_msg;

    values[0] = strdup(value.c_str());
    values[1] = NULL;

    attr.mod_op = LDAP_MOD_ADD;
    attr.mod_type = strdup(attribute.c_str());
    attr.mod_values = values;

    attrs[0] = &attr;
    attrs[1] = NULL;

    result = ldap_modify_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    free(values[0]);
    free(attr.mod_type);
    if (result != LDAP_SUCCESS) {
        error_msg = "Error in mod_add, ldap_modify_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::mod_delete(string object, string attribute, string value) {
/*
  It performs generic LDAP_MOD_DELETE operation on object (short_name/DN).
  It removes value from attribute.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(object);

    LDAPMod *attrs[2];
    LDAPMod attr;
    char *values[2];
    int result;
    string error_msg;

    if (value.empty()) {
        values[0] = NULL;
    } else {
        values[0] = strdup(value.c_str());
    }
    values[1] = NULL;

    attr.mod_op = LDAP_MOD_DELETE;
    attr.mod_type = strdup(attribute.c_str());
    attr.mod_values = values;

    attrs[0] = &attr;
    attrs[1] = NULL;

    result = ldap_modify_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    if (!value.empty()) {
        free(values[0]);
    }
    free(attr.mod_type);
    if (result != LDAP_SUCCESS) {
        error_msg = "Error in mod_delete, ldap_modify_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::mod_move(string object, string new_container) {
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    if (!ifDNExists(new_container)) {
        string error_msg = "Error in mod_move, destination OU does not exists: ";
        error_msg.append(new_container);
        throw ADOperationalException(error_msg, AD_PARAMS_ERROR);
    }

    string dn = getObjectDN(object);

    std::pair<string, string> rdn = explode_dn(dn)[0];
    string newrdn = rdn.first + "=" + rdn.second;

    int result = ldap_rename_s(ds, dn.c_str(), newrdn.c_str(), new_container.c_str(), 1, NULL, NULL);
    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in mod_move, ldap_rename_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::mod_rename(string object, string cn) {
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(object);

    string newrdn = "CN=" + cn;

    int result = ldap_rename_s(ds, dn.c_str(), newrdn.c_str(), NULL, 1, NULL, NULL);
    if (result != LDAP_SUCCESS){
        string error_msg = "Error in mod_rename, ldap_rename_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg,result);
    }
}

void adclient::mod_replace(string object, string attribute, vector <string> list) {
/*
  It performs generic LDAP_MOD_REPLACE operation on object (short_name/DN).
  It removes list from attribute.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(object);

    LDAPMod *attrs[2];
    LDAPMod attr;
    int result;
    string error_msg;
    char** values = new char*[list.size() + 1];
    size_t i;

    for (i = 0; i < list.size(); ++i) {
        values[i] = new char[list[i].size() + 1];
        strcpy(values[i], list[i].c_str());
    }
    values[i] = NULL;

    attr.mod_op = LDAP_MOD_REPLACE;
    attr.mod_type = strdup(attribute.c_str());
    attr.mod_values = values;

    attrs[0] = &attr;
    attrs[1] = NULL;

    result = ldap_modify_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    if (result != LDAP_SUCCESS) {
        error_msg = "Error in mod_replace, ldap_modify_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
    for (i = 0; i < list.size(); ++i) {
        delete[] values[i];
    }
    delete[] values;
    free(attr.mod_type);
}

void adclient::mod_replace(string object, string attribute, string value) {
/*
  It performs generic LDAP_MOD_REPLACE operation on object (short_name/DN).
  It removes value from attribute.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    vector<string> values;
    values.push_back(value);
    return mod_replace(object, attribute, values);
}

void adclient::CreateOU(string ou) {
/*
  It creates given OU (with subOUs if needed).
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ifDNExists(ou)) {
        return;
    }

    vector < std::pair<string, string> > ou_exploded = explode_dn(ou);

    std::pair<string, string> front_ou = ou_exploded.front();
    ou_exploded.erase(ou_exploded.begin());

    string sub_ou = merge_dn(ou_exploded);
    if ((!sub_ou.empty()) && (!ifDNExists(sub_ou))) {
        CreateOU(sub_ou);
    }

    if (upper(front_ou.first) != "OU") {
        string error_msg = "Error in CreateOU, incorrect OU syntax: ";
        error_msg.append(front_ou.first + "=" + front_ou.second);
        throw ADOperationalException(error_msg, AD_PARAMS_ERROR);
    }

    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    LDAPMod *attrs[3];
    LDAPMod attr1, attr2;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    char *objectClass_values[] = {"organizationalUnit", NULL};

    attr1.mod_op = LDAP_MOD_ADD;
    attr1.mod_type = "objectClass";
    attr1.mod_values = objectClass_values;

    char *name_values[2];
    name_values[0] = strdup(front_ou.second.c_str());
    name_values[1] = NULL;

    attr2.mod_op = LDAP_MOD_ADD;
    attr2.mod_type = "name";
    attr2.mod_values = name_values;
#pragma GCC diagnostic pop

    attrs[0] = &attr1;
    attrs[1] = &attr2;
    attrs[2] = NULL;

    int result = ldap_add_ext_s(ds, ou.c_str(), attrs, NULL, NULL);

    free(name_values[0]);

    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in CreateOU, ldap_add_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::DeleteDN(string dn) {
/*
  It deletes given DN.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    int result = ldap_delete_ext_s(ds, dn.c_str(), NULL, NULL);

    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in DeleteDN, ldap_delete_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

string adclient::dn2domain(string dn) {
    string domain = "";

    vector < std::pair<string, string> > dn_exploded = explode_dn(dn);

    vector < std::pair<string, string> >::iterator it;
    for (it = dn_exploded.begin(); it != dn_exploded.end(); ++it) {
        if (upper(it->first) == "DC") {
            domain += it->second;
            domain += ".";
        }
    }
    if (domain.size() > 0) {
        domain.erase(domain.size()-1, 1);
    }
    return domain;
}

string adclient::merge_dn(vector < std::pair<string, string> > dn_exploded) {
    std::stringstream result;

    vector < std::pair<string, string> >::iterator it;
    for (it = dn_exploded.begin(); it != dn_exploded.end(); ++it) {
        result << it->first;
        result << "=";
        result << it->second;
        if (it != dn_exploded.end() - 1) {
            result << ",";
        }
    }
    return result.str();
}

vector < std::pair<string, string> > adclient::explode_dn(string dn) {
#if defined OPENLDAP
#ifdef LDAP21
    LDAPDN *exp_dn;
#else
    LDAPDN exp_dn;
#endif
    int i;
    struct berval la_attr;
    struct berval la_value;
    vector < std::pair<string, string> > dn_exploded;

    int result = ldap_str2dn(dn.c_str(), &exp_dn, LDAP_DN_FORMAT_LDAPV3);

    if (result != LDAP_SUCCESS || exp_dn == NULL) {
        throw ADOperationalException("Wrong OU syntax", AD_OU_SYNTAX_ERROR);
    }

    for (i = 0; exp_dn[i] != NULL; ++i) {
#ifdef LDAP21
        la_attr = (****exp_dn[i]).la_attr;
        la_value = (****exp_dn[i]).la_value;
#else
        la_attr = (**exp_dn[i]).la_attr;
        la_value = (**exp_dn[i]).la_value;
#endif
        dn_exploded.push_back( std::make_pair(la_attr.bv_val, la_value.bv_val) );
    }
    ldap_dnfree(exp_dn);
    return dn_exploded;
}
#elif defined SUNLDAP
    char** dns;
    char* pcDn = strdup(dn.c_str());
    dns = ldap_explode_dn(pcDn, 0);
    free(pcDn);

    char* next;
    unsigned int i = 0;
    vector < std::pair<string, string> > dn_exploded;

    while ((next = dns[i]) != NULL) {
        string temp(next);
        size_t pos = temp.find("=");
        if (pos != temp.npos) {
            string first = temp.substr(0, pos);
            string second = temp.substr(pos+1);
            dn_exploded.push_back( std::make_pair(first, second) );
        }
        i++;
    }
    ldap_value_free(dns);
    return dn_exploded;
}
#else
    throw ADOperationalException("Don't know how to do explode_dn", 255);
}
#endif

void adclient::CreateComputer(string name, string container) {
/*
  It creates computer with given name in given container.
  It will create container if not exists.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    LDAPMod *attrs[4];
    LDAPMod attr1, attr2, attr3;

    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    if (!ifDNExists(container)) CreateOU(container);

    string dn = "CN=" + name + "," + container;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    char *objectClass_values[] = {"top", "person", "organizationalPerson",
        "user", "computer", NULL};
    char *name_values[2];
    char *accountControl_values[] = {"4128", NULL};
    string upn;
    string domain;

    attr1.mod_op = LDAP_MOD_ADD;
    attr1.mod_type = "objectClass";
    attr1.mod_values = objectClass_values;

    std::transform(name.begin(), name.end(), name.begin(), ::toupper);
    name += "$";

    name_values[0] = strdup(name.c_str());
    name_values[1] = NULL;
    attr2.mod_op = LDAP_MOD_ADD;
    attr2.mod_type = "sAMAccountName";
    attr2.mod_values = name_values;

    attr3.mod_op = LDAP_MOD_ADD;
    attr3.mod_type = "userAccountControl";
    attr3.mod_values = accountControl_values;
#pragma GCC diagnostic pop

    attrs[0] = &attr1;
    attrs[1] = &attr2;
    attrs[2] = &attr3;
    attrs[3] = NULL;

    int result;
    result = ldap_add_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    free(name_values[0]);
    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in CreateComputer, ldap_add_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::RenameDN(string object, string cn) {
    string dn = getObjectDN(object);
    mod_rename(dn, cn);
}

void adclient::RenameGroup(string group, string shortname, string cn) {
    string dn = getObjectDN(group);

    if (cn.empty()) {
        cn = shortname;
    }

    mod_replace(dn, "sAMAccountName", shortname);

    mod_rename(dn, cn);
}

void adclient::RenameUser(string user, string shortname, string cn) {
    string dn = getObjectDN(user);

    if (cn.empty()) {
        cn = shortname;
    }

    mod_replace(dn, "sAMAccountName", shortname);

    string upn = shortname + "@" + dn2domain(dn);
    mod_replace(dn, "userPrincipalName", upn);

    mod_rename(dn, cn);
}

void adclient::CreateUser(string cn, string container, string user_short) {
/*
  It creates user with given common name and short name in given container.
  It will create container if not exists.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    LDAPMod *attrs[5];
    LDAPMod attr1, attr2, attr3, attr4;

    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    if (!ifDNExists(container)) CreateOU(container);

    string dn = "CN=" + cn + "," + container;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    char *objectClass_values[] = {"user", NULL};
    char *name_values[2];
    char *accountControl_values[] = {"66050", NULL};
    char *upn_values[2];
    string upn;
    string domain;

    attr1.mod_op = LDAP_MOD_ADD;
    attr1.mod_type = "objectClass";
    attr1.mod_values = objectClass_values;

    name_values[0] = strdup(user_short.c_str());
    name_values[1] = NULL;
    attr2.mod_op = LDAP_MOD_ADD;
    attr2.mod_type = "sAMAccountName";
    attr2.mod_values = name_values;

    attr3.mod_op = LDAP_MOD_ADD;
    attr3.mod_type = "userAccountControl";
    attr3.mod_values = accountControl_values;

    domain = dn2domain(dn);
    upn = user_short + "@" + domain;
    upn_values[0] = strdup(upn.c_str());
    upn_values[1] = NULL;
    attr4.mod_op = LDAP_MOD_ADD;
    attr4.mod_type = "userPrincipalName";
    attr4.mod_values = upn_values;
#pragma GCC diagnostic pop

    attrs[0] = &attr1;
    attrs[1] = &attr2;
    attrs[2] = &attr3;
    attrs[3] = &attr4;
    attrs[4] = NULL;

    int result;
    result = ldap_add_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    free(name_values[0]);
    free(upn_values[0]);
    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in CreateUser, ldap_add_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

void adclient::CreateGroup(string cn, string container, string group_short) {
/*
  It creates new global security group with
    samaccountname=group_short and distinguishedName="CN=cn,container"
  It will create container if not exists.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
 */
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    LDAPMod *attrs[4];
    LDAPMod attr1, attr2, attr3;

    if (!ifDNExists(container)) CreateOU(container);

    string dn = "CN=" + cn + "," + container;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    char *objectClass_values[] = {"group", NULL};
    char *name_values[2];
    char *sAMAccountName_values[2];

    attr1.mod_op = LDAP_MOD_ADD;
    attr1.mod_type = "objectClass";
    attr1.mod_values = objectClass_values;

    name_values[0] = strdup(group_short.c_str());
    name_values[1] = NULL;
    attr2.mod_op = LDAP_MOD_ADD;
    attr2.mod_type = "name";
    attr2.mod_values = name_values;

    sAMAccountName_values[0] = strdup(group_short.c_str());
    sAMAccountName_values[1] = NULL;
    attr3.mod_op = LDAP_MOD_ADD;
    attr3.mod_type = "sAMAccountName";
    attr3.mod_values = sAMAccountName_values;
#pragma GCC diagnostic pop

    attrs[0] = &attr1;
    attrs[1] = &attr2;
    attrs[2] = &attr3;
    attrs[3] = NULL;

    int result;
    result = ldap_add_ext_s(ds, dn.c_str(), attrs, NULL, NULL);
    free(name_values[0]);
    free(sAMAccountName_values[0]);
    if (result != LDAP_SUCCESS) {
        string error_msg = "Error in CreateGroup, ldap_add_ext_s: ";
        error_msg.append(ldap_err2string(result));
        throw ADOperationalException(error_msg, result);
    }
}

struct berval adclient::password2berval(string password) {
/*
  Convert string password to unicode quoted bervalue.
  Caller must explicitly free bv_val field with delete[].
*/
    struct berval pw;

    string quoted_password = "\"" + password + "\"";

    pw.bv_len = quoted_password.size()*2;

    pw.bv_val = new char[pw.bv_len]();
    memset(pw.bv_val, 0, pw.bv_len);

    for (unsigned int i = 0; i < quoted_password.size(); ++i) {
        pw.bv_val[i*2] = quoted_password[i];
    }

    return pw;
}

void adclient::changeUserPassword(string user, string old_password, string new_password) {
/*
  It changes user password (does not require administrative rights, only old password required).
  According to https://msdn.microsoft.com/en-us/library/cc223248.aspx
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(user);

    LDAPMod *attrs[3];
    LDAPMod attr1, attr2;
    struct berval *old_bervalues[2], *new_bervalues[2];

    struct berval old_pw = adclient::password2berval(old_password);
    old_bervalues[0] = &old_pw;
    old_bervalues[1] = NULL;

    struct berval new_pw = adclient::password2berval(new_password);
    new_bervalues[0] = &new_pw;
    new_bervalues[1] = NULL;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    attr1.mod_type = "unicodePwd";
#pragma GCC diagnostic pop
    attr1.mod_op = LDAP_MOD_DELETE|LDAP_MOD_BVALUES;
    attr1.mod_bvalues = old_bervalues;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    attr2.mod_type = "unicodePwd";
#pragma GCC diagnostic pop
    attr2.mod_op = LDAP_MOD_ADD|LDAP_MOD_BVALUES;
    attr2.mod_bvalues = new_bervalues;

    attrs[0] = &attr1;
    attrs[1] = &attr2;
    attrs[2] = NULL;

    int result;

    result = ldap_modify_ext_s(ds, dn.c_str(), attrs, NULL, NULL);

    delete[] old_pw.bv_val;
    delete[] new_pw.bv_val;

    if (result != LDAP_SUCCESS) {
       string error_msg = "Error in changeUserPassord, ldap_modify_ext_s: ";
       error_msg.append(ldap_err2string(result));
       throw ADOperationalException(error_msg, result);
    }
}

void adclient::setUserPassword(string user, string password) {
/*
  It sets user password.
  It returns nothing if operation was successfull, throw ADOperationalException - otherwise.
*/
    if (ds == NULL) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    string dn = getObjectDN(user);

    LDAPMod *attrs[2];
    LDAPMod attr1;
    struct berval *bervalues[2];
    struct berval pw = adclient::password2berval(password);

    bervalues[0] = &pw;
    bervalues[1] = NULL;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
    attr1.mod_type = "unicodePwd";
#pragma GCC diagnostic pop
    attr1.mod_op = LDAP_MOD_REPLACE|LDAP_MOD_BVALUES;
    attr1.mod_bvalues = bervalues;

    attrs[0] = &attr1;
    attrs[1] = NULL;

    int result;

    result = ldap_modify_ext_s(ds, dn.c_str(), attrs, NULL, NULL);

    delete[] pw.bv_val;

    if (result != LDAP_SUCCESS) {
       string error_msg = "Error in setUserPassord, ldap_add_ext_s: ";
       error_msg.append(ldap_err2string(result));
       throw ADOperationalException(error_msg, result);
    }
}

vector <string> adclient::getObjectAttribute(string object, string attribute) {
/*
  It returns vector of strings with values for given attribute.
*/
    vector <string> attributes;
    attributes.push_back(attribute);

    map < string, vector<string> > attrs;
    attrs = getObjectAttributes(object, attributes);

    try {
        return attrs.at(attribute);
    }
    catch (const std::out_of_range&) {
        throw ADSearchException("No such attribute '" + attribute + "' in '" + object + "'", AD_ATTRIBUTE_ENTRY_NOT_FOUND);
    }
}

map <string, vector <string> > adclient::getObjectAttributes(string object) {
/*
  It returns map of all object attributes.
*/
    vector <string> attributes;
    attributes.push_back("*");
    return getObjectAttributes(object, attributes);
}

map <string, vector <string> > adclient::getObjectAttributes(string object, const vector<string> &attributes) {
/*
  It returns map of given object attributes.
*/
    string dn = getObjectDN(object);

    map < string, map < string, vector<string> > > search_result;

    search_result = search(dn, LDAP_SCOPE_BASE, "(objectclass=*)", attributes);

    map < string, vector<string> > attrs;
    try {
        attrs = search_result.at(dn);
    }
    catch (const std::out_of_range&) {
        attrs = map < string, vector<string> >();
    }

    // on-fly convertion of objectSid from binary to string
    // not sure if it should be done here as end user could want to see actual binary data
    // and covert it only if it is required.
//    map < string, vector<string> >::iterator it = attrs.find("objectSid");
//    if (it != attrs.end()) {
//        vector<string> sid;
//        for (unsigned int i = 0; i < it->second.size(); ++i) {
//            sid.push_back( decodeSID(it->second[i]) );
//        }
//        it->second = sid;
//    }

    return attrs;
}

void adclient::groupAddUser(string group, string user) {
/*
  Simple wrapper for mod_add to perform LDAP_MOD_ADD user operation only
         on member attribure of group_dn.
*/
    string dn = getObjectDN(user);

    mod_add(group, "member", dn);
}

void adclient::groupRemoveUser(string group, string user) {
/*
  Simple wrapper for mod_delete to perform LDAP_MOD_DELETE user operation only
         on member attribure of group.
*/
    string dn = getObjectDN(user);

    mod_delete(group, "member", dn);
}


vector <string> adclient::getUserGroups(string user, bool nested) {
/*
  It return vector of strings with user groups.
*/
    vector <string> groups;

    if (nested) {
        string dn = getObjectDN(user);
        try {
            groups = searchDN(params.search_base, "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + dn + "))", LDAP_SCOPE_SUBTREE);
        } catch (ADSearchException& ex) {
            if (ex.code == AD_OBJECT_NOT_FOUND) {
                return vector<string>();
            }
            throw;
        }
    } else {
        try {
            groups = getObjectAttribute(user, "memberOf");
        } catch (ADSearchException& ex) {
            if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND) {
                return vector<string>();
            }
            throw;
        }
    }

    return DNsToShortNames(groups);
}

vector <string> adclient::getUsersInGroup(string group, bool nested) {
/*
  It return vector of strings with members of Active Directory "group".
*/
    vector <string> users;

    if (nested) {
        string dn = getObjectDN(group);
        try {
            // this will return only users in group
            users = searchDN(params.search_base, "(&(objectClass=user)(objectCategory=person)(memberOf:1.2.840.113556.1.4.1941:=" + dn + "))", LDAP_SCOPE_SUBTREE);
        } catch (ADSearchException& ex) {
            if (ex.code == AD_OBJECT_NOT_FOUND) {
                return vector<string>();
            }
            throw;
        }
    } else {
        try {
            // this will return not only users in group but groups in group too
            users = getObjectAttribute(group, "member");
        } catch (ADSearchException& ex) {
            if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND) {
                return vector <string>();
            }
            throw;
        }
    }
    return DNsToShortNames(users);
}

bool adclient::ifDialinUser(string user) {
/*
  It returns true if msNPAllowDialin user attribute set to TRUE,
             false - otherwise.
*/
    vector <string> user_dn;
    vector <string> dialin;

    try {
        dialin = getObjectAttribute(user, "msNPAllowDialin");
    }
    catch (ADSearchException& ex) {
        if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND) {
            return false;
        }
        throw;
    }

    if (dialin[0] == "TRUE") {
        return true;
    } else  { return false; }
}

vector <string> adclient::getDialinUsers() {
/*
  It returns vector of strings with all users with msNPAllowDialin = TRUE.
*/
    vector <string> users_dn;

    users_dn = searchDN(params.search_base, "(msNPAllowDialin=TRUE)", LDAP_SCOPE_SUBTREE);

    return DNsToShortNames(users_dn);
}

vector <string> adclient::getDisabledUsers() {
/*
  It returns vector of strings with all users with ADS_UF_ACCOUNTDISABLE in userAccountControl.
*/
    vector <string> users_dn;

    users_dn = searchDN(params.search_base, "(&(objectClass=user)(objectCategory=person)(userAccountControl:1.2.840.113556.1.4.803:=2))", LDAP_SCOPE_SUBTREE);

    return DNsToShortNames(users_dn);
}


string adclient::getUserDisplayName(string user) {
/*
  It returns string with DisplayName of user.
*/
    vector <string> name;
    try {
        name = getObjectAttribute(user, "displayName");
    }
    catch (ADSearchException& ex) {
        if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND) {
            return "";
        }
        throw;
    }
    return name[0];
}

string adclient::getUserIpAddress(string user) {
    vector <string> tmp;
    try {
        tmp = getObjectAttribute(user, "msRADIUSFramedIPAddress");
    }
    catch (ADSearchException& ex) {
        if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND) {
            return "";
        }
        throw;
    }
    try {
        if (!tmp[0].empty()) {
            return int2ip(tmp[0]);
        }
    } catch (std::invalid_argument& ex) {
        throw ADOperationalException(ex.what(), AD_PARAMS_ERROR);
    }
    return "";
}

/*
Pwd-Last-Set attribute - http://msdn.microsoft.com/en-us/library/windows/desktop/ms679430%28v=vs.85%29.aspx
Account-Expires attribute - http://msdn.microsoft.com/en-us/library/windows/desktop/ms675098%28v=vs.85%29.aspx
ms-DS-User-Account-Control-Computed attribute - http://msdn.microsoft.com/en-us/library/ms677840(v=vs.85).aspx
UserAccountControl - http://support.microsoft.com/kb/305144/en-us
*/
map <string, bool> adclient::getUserControls(string user) {
/*
  It returns boolean map of user controls ('disabled', 'locked', 'dontExpirePassword', 'mustChangePassword', 'expired').
*/
    vector <string> attrs;
    attrs.push_back("userAccountControl");
    attrs.push_back("msDS-User-Account-Control-Computed");
    attrs.push_back("pwdLastSet");
    attrs.push_back("accountExpires");

    map <string, vector <string> > flags;
    flags = getObjectAttributes(user, attrs);

    int iflags1 = atoi(flags["userAccountControl"][0].c_str());
    int iflags2 = atoi(flags["msDS-User-Account-Control-Computed"][0].c_str());
    int iflags3 = atoi(flags["pwdLastSet"][0].c_str());

    long long iflags4 = atoll(flags["accountExpires"][0].c_str());
    time_t expires = FileTimeToPOSIX(iflags4);
    time_t now = time(0);

    map <string, bool> controls;

    controls["disabled"] = (iflags1 & 2);
    controls["locked"] = (iflags2 & 16);

    controls["dontExpirePassword"] = (iflags1 & 65536);
    controls["mustChangePassword"] = ((iflags3 == 0) && (!controls["dontExpirePassword"]));

    controls["expired"] = (now > expires);

    return controls;
}

bool adclient::getUserControl(string user, string control) {
/*
  It returns given user control from adclient::getUserControls.
*/
    map <string, bool> controls;
    controls = getUserControls(user);
    return controls[control];
}

bool adclient::ifUserExpired(string user) {
/*
  It returns 'expired' user control value.
*/
    return getUserControl(user, "expired");
}

bool adclient::ifUserLocked(string user) {
/*
  It returns 'locked' user control value.
*/
    return getUserControl(user, "locked");
}

bool adclient::ifUserDisabled(string user) {
/*
  It returns 'disabled' user control value.
*/
    return getUserControl(user, "disabled");
}

bool adclient::ifUserMustChangePassword(string user) {
/*
  It returns 'mustChangePassword' user control value.
*/
    return getUserControl(user, "mustChangePassword");
}

bool adclient::ifUserDontExpirePassword(string user) {
/*
  It returns 'dontExpirePassword' user control value.
*/
    return getUserControl(user, "dontExpirePassword");
}

vector <string> adclient::getOUs() {
/*
  It returns vector of strings with all organizationalUnit in Active Directory.
*/
    return getOUsInOU(params.search_base, LDAP_SCOPE_SUBTREE);
}

vector <string> adclient::getGroups() {
/*
  It returns vector of strings with all groups in Active Directory.
*/
    vector<string> dns = getGroupsInOU(params.search_base, LDAP_SCOPE_SUBTREE);
    return DNsToShortNames( dns );
}

vector <string> adclient::getUsers() {
/*
  It returns vector of strings with all users in Active Directory.
*/
    vector<string> dns = getUsersInOU(params.search_base, LDAP_SCOPE_SUBTREE);
    return DNsToShortNames( dns );
}

vector <string> adclient::getGroupsInOU(string OU, int scope) {
/*
  It returns vector of DNs with OU's in OU.
  scope defines how deep to search within the search base.
*/
    return getObjectsInOU(OU, "(objectclass=group)", scope);
}

vector <string> adclient::getComputersInOU(string OU, int scope) {
/*
  It returns vector of DNs with OU's in OU.
  scope defines how deep to search within the search base.
*/
    return getObjectsInOU(OU, "(objectclass=computer)", scope);
}

vector <string> adclient::getOUsInOU(string OU, int scope) {
/*
  It returns vector of DNs with OU's in OU.
  scope defines how deep to search within the search base.
*/
    return getObjectsInOU(OU, "(objectclass=organizationalUnit)", scope);
}

vector <string> adclient::getUsersInOU(string OU, int scope) {
/*
  It returns vector of DNs with OU's in OU,
  scope defines how deep to search within the search base.
*/
    return getObjectsInOU(OU, "(&(objectClass=user)(objectCategory=person))", scope);
}

vector <string> adclient::getObjectsInOU(string OU, string filter, int scope) {
/*
  It returns vector of objects DNs in OU,
  filter allows certain entries and excludes others,
  scope defines how deep to search within the search base.
*/
    vector <string> dns = searchDN(OU, filter, scope);

    vector <string> OUs;
    for (unsigned int i = 0; i < dns.size(); ++i) {
        OUs.push_back(dns[i]);
    }
    return OUs;
}

void adclient::EnableUser(string user) {
/*
  It enables given user.
*/
    vector <string> flags = getObjectAttribute(user, "userAccountControl");

    int iflags = atoi(flags[0].c_str());
    int oldflags = iflags&2;

    if (oldflags) {
        int newflags = iflags^2;
        mod_replace(user, "userAccountControl", itos(newflags));
    }
}

void adclient::DisableUser(string user) {
/*
  It disables given user.
*/
    vector <string> flags = getObjectAttribute(user, "userAccountControl");

    int iflags = atoi(flags[0].c_str());
    int oldflags = iflags&2;

    if (!oldflags) {
        int newflags = iflags^2;
        mod_replace(user, "userAccountControl", itos(newflags));
    }
}

void adclient::MoveObject(string object, string new_container) {
    string dn = getObjectDN(object);
    mod_move(dn, new_container);
}

void adclient::MoveUser(string user, string new_container) {
    string dn = getObjectDN(user);

    string shortname = getObjectAttribute(dn, "sAMAccountName")[0];
    string upn = getObjectAttribute(dn, "userPrincipalName")[0];

    mod_move(dn, new_container);

    string newUpn = shortname + "@" + dn2domain(new_container);
    if (upn != newUpn) {
        // this will not work if shortname was moved to different search base
        dn = getObjectDN(shortname);
        mod_replace(dn, "userPrincipalName", newUpn);
    }
}

void adclient::UnLockUser(string user) {
    mod_replace(user, "lockoutTime", "0");
}

void adclient::setUserDescription(string user, string descr) {
    mod_replace(user, "description", descr);

}

void adclient::setUserPhone(string user, string phone) {
    mod_replace(user, "telephoneNumber", phone);
}

void adclient::setUserDialinAllowed(string user) {
    mod_replace(user, "msNPAllowDialin", "TRUE");
}

void adclient::setUserDialinDisabled(string user) {
    mod_replace(user, "msNPAllowDialin", "FALSE");
}

void adclient::setUserSN(string user, string sn) {
    mod_replace(user, "sn", sn);
}

void adclient::setUserInitials(string user, string initials) {
    mod_replace(user, "initials", initials);
}

void adclient::setUserGivenName(string user, string givenName) {
    mod_replace(user, "givenName", givenName);
}

void adclient::setUserDisplayName(string user, string displayName) {
    mod_replace(user, "displayName", displayName);
}

void adclient::setUserRoomNumber(string user, string roomNum) {
    mod_replace(user, "physicalDeliveryOfficeName", roomNum);
}

void adclient::setUserAddress(string user, string streetAddress) {
    mod_replace(user, "streetAddress", streetAddress);
}

void adclient::setUserInfo(string user, string info) {
    mod_replace(user, "info", info);
}

void adclient::setUserTitle(string user, string title) {
    mod_replace(user, "title", title);
}

void adclient::setUserDepartment(string user, string department) {
    mod_replace(user, "department", department);
}

void adclient::setUserCompany(string user, string company) {
    mod_replace(user, "company", company);
}

void adclient::setUserIpAddress(string user, string ip) {
    try {
        int ipdec = ip2int(ip);
        mod_replace(user, "msRADIUSFramedIPAddress", itos(ipdec));
    } catch (std::invalid_argument& ex) {
        throw ADOperationalException(ex.what(), AD_PARAMS_ERROR);
    }
}

void adclient::clearObjectAttribute(string object, string attr) {
    mod_delete(object, attr, "");
}

void adclient::setObjectAttribute(string object, string attr, string value) {
    mod_replace(object, attr, value);
}

void adclient::setObjectAttribute(string object, string attr, vector <string> values) {
    mod_replace(object, attr, values);
}

/*
AD can set following limit (http://support.microsoft.com/kb/315071/en-us):
 MaxValRange - This value controls the number of values that are returned
   for an attribute of an object, independent of how many attributes that
   object has, or of how many objects were in the search result. If an
   attribute has more than the number of values that are specified by the
   MaxValRange value, you must use value range controls in LDAP to retrieve
   values that exceed the MaxValRange value. MaxValueRange controls the
   number of values that are returned on a single attribute on a single object.

OpenLDAP does not support ranged controls for values:
  https://www.mail-archive.com/openldap-its@openldap.org/msg00962.html

So the only way is it increase MaxValRange in DC:
 Ntdsutil.exe
   LDAP policies
     connections
       connect to server "DNS name of server"
       q
     Show Values
     Set MaxValRange to 10000
     Show Values
     Commit Changes
     Show Values
     q
   q
*/
map < string, vector<string> > adclient::_getvalues(LDAPMessage *entry) {
    if ((ds == NULL) || (entry == NULL)) throw ADSearchException("Failed to use LDAP connection handler", AD_LDAP_CONNECTION_ERROR);

    map < string, vector<string> > result;

    BerElement *berptr;

    struct berval data;

    for ( char *next = ldap_first_attribute(ds, entry, &berptr);
          next != NULL;
          next = ldap_next_attribute(ds, entry, berptr) ) {
        vector <string> temp;
        struct berval **values = ldap_get_values_len(ds, entry, next);
        if (values == NULL) {
            string error = "Error in ldap_get_values_len for _getvalues: no values found";
            throw ADSearchException(error, AD_ATTRIBUTE_ENTRY_NOT_FOUND);
        }
        for (unsigned int i = 0; values[i] != NULL; ++i) {
            data = *values[i];
            temp.push_back(string(data.bv_val, data.bv_len));
        }
        result[next] = temp;
        // cout << "_getvalues['" << next << "'] = '" << vector2string(temp) << "'" << endl;
        ldap_memfree(next);
        ldap_value_free_len(values);
    }

    ber_free(berptr, 0);

    return result;
}

vector <string> adclient::DNsToShortNames(vector <string> &v) {
    vector <string> result;

    vector <string>::iterator it;
    for (it = v.begin(); it != v.end(); ++it) {
        vector <string> short_v;
        try {
            short_v = getObjectAttribute(*it, "sAMAccountName");
        }
        catch (ADSearchException& ex) {
            if (ex.code == AD_ATTRIBUTE_ENTRY_NOT_FOUND ||
                // object could be not found if it is in a different search base / domain
                ex.code == AD_OBJECT_NOT_FOUND) {
                result.push_back(*it);
                continue;
            }
            throw;
        }
        result.push_back(short_v[0]);
    }
    return result;
}

string adclient::domain2dn(string domain) {
    replace(domain, ".", ",DC=");
    return "DC=" + domain;
}

vector<string> adclient::get_ldap_servers(string domain, string site) {
    vector<string> servers;
    if (!site.empty()) {
        string srv_site = "_ldap._tcp." + site + "._sites." + domain;
        try {
            servers = perform_srv_query(srv_site);
        } catch (ADBindException &ex) { }
    }

    string srv_default = "_ldap._tcp." + domain;
    vector<string> servers_default = perform_srv_query(srv_default);

    // extend site DCs list with all DCs list (except already added site DCs) in case when site DCs is unavailable
    for (vector <string>::iterator it = servers_default.begin(); it != servers_default.end(); ++it) {
        if (find(servers.begin(), servers.end(), *it) == servers.end()) {
            servers.push_back(*it);
        }
    }

    return servers;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
// this magic was copy pasted and adopted from
// https://www.ccnx.org/releases/latest/doc/ccode/html/ccndc-srv_8c_source.html
vector<string> adclient::perform_srv_query(string srv_rec) {
    union dns_ans {
             HEADER header;
             unsigned char buf[NS_MAXMSG];
          } ans;
    size_t ans_size;

    char *srv_name = strdup(srv_rec.c_str());
    if (!srv_name) {
        throw ADBindException("Failed to allocate memory for srv_rec", AD_LDAP_RESOLV_ERROR);
    }
    ans_size = res_search(srv_name, ns_c_in, ns_t_srv, ans.buf, sizeof(ans.buf));

    int qdcount, ancount;
    qdcount = ntohs(ans.header.qdcount);
    ancount = ntohs(ans.header.ancount);

    unsigned char *msg, *msgend;
    msg = ans.buf + sizeof(ans.header);
    msgend = ans.buf + ans_size;

    int size = 0, i;
    for (i = qdcount; i > 0; --i) {
        if ((size = dn_skipname(msg, msgend)) < 0) {
            free(srv_name);
            throw ADBindException("Error while resolving ldap server for " + srv_rec + ": dn_skipname < 0", AD_LDAP_RESOLV_ERROR);
        }
        msg = msg + size + QFIXEDSZ;
    }

    int type = 0, priority = 0, weight = 0, port = 0, recclass = 0, ttl = 0;
    unsigned char *end;
    char host[NS_MAXDNAME];

    vector<string> ret;
    for (i = ancount; i > 0; --i) {
        size = dn_expand(ans.buf, msgend, msg, srv_name, strlen(srv_name)+1);
        if (size < 0) {
            free(srv_name);
            throw ADBindException("Error while resolving ldap server for " + srv_rec + ": dn_expand(srv_name) < 0", AD_LDAP_RESOLV_ERROR);
        }
        msg = msg + size;

        GETSHORT(type, msg);
        GETSHORT(recclass, msg);
        GETLONG(ttl, msg);
        GETSHORT(size, msg);
        if ((end = msg + size) > msgend) {
            free(srv_name);
            throw ADBindException("Error while resolving ldap server for " + srv_rec + ": (msg + size) > msgend", AD_LDAP_RESOLV_ERROR);
        }

        if (type != ns_t_srv) {
            msg = end;
            continue;
        }

        GETSHORT(priority, msg);
        GETSHORT(weight, msg);
        GETSHORT(port, msg);
        size = dn_expand(ans.buf, msgend, msg, host, sizeof(host));
        if (size < 0) {
            free(srv_name);
            throw ADBindException("Error while resolving ldap server for " + srv_rec + ": dn_expand(host) < 0", AD_LDAP_RESOLV_ERROR);
        }
        // std::cout << priority << " " << weight << " " << ttl << " " << host << ":" << port << std::endl;
        ret.push_back(string(host));
        msg = end;
    }
    free(srv_name);
    return ret;
}
#pragma GCC diagnostic pop
