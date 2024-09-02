// +build ignore

/*
  Python wrapper around C++ class.
*/
#include <Python.h>
#include "adclient.h"

static PyObject *ADBindError;
static PyObject *ADSearchError;
static PyObject *ADOperationalError;
static int error_num;

PyObject *vector2list(vector <string> vec) {
       string st;
       PyObject *list = PyList_New(vec.size());;

       for (unsigned int j=0; (j < vec.size()); j++) {
           if (PyList_SetItem(list, j, PyString_FromStringAndSize(vec[j].c_str(), vec[j].size())) < 0)
              return NULL;
       }
       return list;
}

adclient *convert_ad(PyObject *obj) {
       void * temp = PyCObject_AsVoidPtr(obj);
       return static_cast<adclient*>(temp);
}

static PyObject *wrapper_get_error_num(PyObject *self, PyObject *args) {
       return Py_BuildValue("i", error_num);
}

static PyObject *wrapper_domain2dn(PyObject *self, PyObject *args) {
       char *domain;
       if (!PyArg_ParseTuple(args, "s", &domain)) return NULL;
       string result = adclient::domain2dn(domain);
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_decodeSID(PyObject *self, PyObject *args) {
       char *sid;
       int len;
       if (!PyArg_ParseTuple(args, "s#", &sid, &len)) return NULL;
       string result = decodeSID(string(sid, len));
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_FileTimeToPOSIX(PyObject *self, PyObject *args) {
       long long filetime;
       if (!PyArg_ParseTuple(args, "L", &filetime)) return NULL;
       time_t result = FileTimeToPOSIX(filetime);
       return Py_BuildValue("i", result);
}

static PyObject *wrapper_get_ldap_servers(PyObject *self, PyObject *args) {
       char *domain, *site;
       if (!PyArg_ParseTuple(args, "ss", &domain, &site)) return NULL;
       vector <string> result = adclient::get_ldap_servers(domain, site);
       return vector2list(result);
}

static PyObject *wrapper_int2ip(PyObject *self, PyObject *args) {
       char *ipstr;
       if (!PyArg_ParseTuple(args, "s", &ipstr)) return NULL;
       string result = int2ip(ipstr);
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_new_adclient(PyObject *self, PyObject *args) {
       error_num = 0;
       adclient *obj = new adclient();
       return PyCObject_FromVoidPtr(obj, NULL);
}

string dict_get_string(PyObject *dict, string key_str) {
       string result;

       PyObject *key = PyString_FromString(key_str.c_str());
       if (PyDict_Contains(dict, key) == 1) {
           PyObject *val = PyDict_GetItem(dict, key);
           if (PyString_Check(val)) {
               result = PyString_AsString(val);
           }
       }
       Py_DECREF(key);
       return result;
}

bool dict_get_bool(PyObject *dict, string key_str) {
       bool result = false;

       PyObject *key = PyString_FromString(key_str.c_str());
       if (PyDict_Contains(dict, key) == 1) {
           PyObject *val = PyDict_GetItem(dict, key);
           result = PyObject_IsTrue(val);
       }
       Py_DECREF(key);
       return result;
}

int dict_get_int(PyObject *dict, string key_str) {
       int result = -1;

       PyObject *key = PyString_FromString(key_str.c_str());
       if (PyDict_Contains(dict, key) == 1) {
           PyObject *val = PyDict_GetItem(dict, key);
           result = PyInt_AsLong(val);
       }
       Py_DECREF(key);
       return result;
}

static PyObject *wrapper_login_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       PyObject *paramsObj;

       if (!PyArg_ParseTuple(args, "OO!", &obj, &PyDict_Type, &paramsObj)) return NULL;

       adConnParams params;

       params.domain = dict_get_string(paramsObj, "domain");
       params.site = dict_get_string(paramsObj, "site");
       params.binddn = dict_get_string(paramsObj, "binddn");
       params.bindpw = dict_get_string(paramsObj, "bindpw");
       params.search_base = dict_get_string(paramsObj, "search_base");
       params.secured = dict_get_bool(paramsObj, "secured");
       params.use_gssapi = dict_get_bool(paramsObj, "use_gssapi");
       params.use_tls = dict_get_bool(paramsObj, "use_tls");
       params.use_ldaps = dict_get_bool(paramsObj, "use_ldaps");
       params.nettimeout = dict_get_int(paramsObj, "nettimeout");
       params.timelimit = dict_get_int(paramsObj, "timelimit");

       PyObject *key = PyString_FromString("uries");
       if (PyDict_Contains(paramsObj, key) == 1) {
            PyObject *val = PyDict_GetItem(paramsObj, key);
            if (PyList_Check(val)) {
               for (unsigned int i = 0; i < PyList_Size(val); i++) {
                  PyObject *strObj = PyList_GetItem(val, i);
                  if (PyString_Check(strObj)) {
                      string item = PyString_AsString(strObj);
                      params.uries.push_back(item);
                  }
               }
            }
       }
       Py_DECREF(key);

       adclient *ad = convert_ad(obj);
       try {
          ad->login(params);
       }
       catch (ADBindException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADBindError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_binded_uri_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;

       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;

       adclient *ad = convert_ad(obj);
       return Py_BuildValue("s", ad->binded_uri().c_str());
}

static PyObject *wrapper_search_base_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;

       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;

       adclient *ad = convert_ad(obj);
       return Py_BuildValue("s", ad->search_base().c_str());
}

static PyObject *wrapper_login_method_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;

       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;

       adclient *ad = convert_ad(obj);
       return Py_BuildValue("s", ad->login_method().c_str());
}

static PyObject *wrapper_bind_method_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;

       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;

       adclient *ad = convert_ad(obj);
       return Py_BuildValue("s", ad->bind_method().c_str());
}

static PyObject *wrapper_search_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *ou, *filter;
       PyObject * listObj;
       int scope;

       map < string, map < string, vector<string> > > res;

       if (!PyArg_ParseTuple(args, "OsisO!", &obj, &ou, &scope, &filter, &PyList_Type, &listObj)) return NULL;

       vector <string> attrs;

       for (unsigned int i = 0; i < PyList_Size(listObj); ++i) {
          PyObject *strObj = PyList_GetItem(listObj, i);
          string item = PyString_AsString(strObj);
          attrs.push_back(item);
       }

       adclient *ad = convert_ad(obj);
       try {
          res = ad->search(ou, scope, filter, attrs);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }

       PyObject *res_dict = PyDict_New();
       map < string, map < string, vector<string> > >::iterator res_it;
       for ( res_it=res.begin() ; res_it != res.end(); ++res_it ) {
           PyObject *attrs_dict = PyDict_New();
           string dn = (*res_it).first;
           map < string, vector<string> > attrs = (*res_it).second;
           map < string, vector<string> >::iterator attrs_it;
           for ( attrs_it=attrs.begin() ; attrs_it != attrs.end(); ++attrs_it ) {
               string attribute = (*attrs_it).first;
               vector<string> values_v = (*attrs_it).second;
               PyObject *values_list = vector2list(values_v);
               if (PyDict_SetItemString(attrs_dict, attribute.c_str(), values_list) < 0) return NULL;
           }
           if (PyDict_SetItemString(res_dict, dn.c_str(), attrs_dict) < 0) return NULL;
       }
       return res_dict;
}

static PyObject *wrapper_searchDN_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *search_base, *filter;
       int scope;

       vector <string> result;
       if (!PyArg_ParseTuple(args, "Ossi", &obj, &search_base, &filter, &scope)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->searchDN(search_base, filter, scope);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUserGroups_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       int nested;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "Osi", &obj, &user, &nested)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUserGroups(user, nested);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUsersInGroup_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *group;
       int nested;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "Osi", &obj, &group, &nested)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUsersInGroup(group, nested);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUserControls_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       map <string, bool> result;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
            result = ad->getUserControls(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       PyObject *res_dict = PyDict_New();
       map <string, bool>::iterator it;
       for (it = result.begin(); it != result.end(); ++it) {
            if (PyDict_SetItemString(res_dict, (*it).first.c_str(), PyBool_FromLong((*it).second)) < 0)
                 return NULL;
       }

       return res_dict;
}

static PyObject *wrapper_groupAddUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *group, *user;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &group, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->groupAddUser(group, user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_groupRemoveUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *group, *user;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &group, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->groupRemoveUser(group, user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_ifDialinUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          return Py_BuildValue("i", ad->ifDialinUser(user));
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
}

static PyObject *wrapper_getDialinUsers_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getDialinUsers();
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getDisabledUsers_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getDisabledUsers();
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getObjectDN_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       string result;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getObjectDN(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_ifUserDisabled_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          return Py_BuildValue("N", PyBool_FromLong(ad->ifUserDisabled(user)));
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
}

static PyObject *wrapper_ifDNExists_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *dn;
       char *objectclass;

       if (!PyArg_ParseTuple(args, "Oss", &obj, &dn, &objectclass)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          return Py_BuildValue("N", PyBool_FromLong(ad->ifDNExists(dn, objectclass)));
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
}

static PyObject *wrapper_getOUs_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       vector <string> result;

       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getOUs();
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getOUsInOU_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *OU;
       int scope;

       vector <string> result;

       if (!PyArg_ParseTuple(args, "Osi", &obj, &OU, &scope)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getOUsInOU(OU, scope);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUsersInOU_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *OU;
       int scope;

       vector <string> result;

       if (!PyArg_ParseTuple(args, "Osi", &obj, &OU, &scope)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUsersInOU(OU, scope);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getComputersInOU_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *OU;
       int scope;

       vector <string> result;

       if (!PyArg_ParseTuple(args, "Osi", &obj, &OU, &scope)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getComputersInOU(OU, scope);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getGroupsInOU_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *OU;
       int scope;

       vector <string> result;

       if (!PyArg_ParseTuple(args, "Osi", &obj, &OU, &scope)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getGroupsInOU(OU, scope);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getGroups_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getGroups();
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUsers_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "O", &obj)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUsers();
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getUserDisplayName_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user_short;
       string result;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user_short)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUserDisplayName(user_short);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_getUserIpAddress_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user_short;
       string result;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user_short)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getUserIpAddress(user_short);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return Py_BuildValue("s", result.c_str());
}

static PyObject *wrapper_getObjectAttribute_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user_short, *attribute;
       vector <string> result;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user_short, &attribute)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getObjectAttribute(user_short, attribute);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       return vector2list(result);
}

static PyObject *wrapper_getObjectAttributes_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *object_short;
       map <string, vector <string> > result;
       if (!PyArg_ParseTuple(args, "Os", &obj, &object_short)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          result = ad->getObjectAttributes(object_short);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }

       string attr;
       vector <string> values;

       PyObject *res_dict = PyDict_New();

       map<string, vector<string> >::iterator it;
       for (it = result.begin(); it != result.end(); ++it) {
           attr = it->first;
           values = it->second;
           PyObject *temp_list = vector2list(values);
           PyDict_SetItemString(res_dict, attr.c_str(), temp_list);
       }
       return res_dict;
}

static PyObject *wrapper_CreateComputer_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *name, *container;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &name, &container)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->CreateComputer(name, container);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_CreateUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *cn, *short_name, *container;
       if (!PyArg_ParseTuple(args, "Osss", &obj, &cn, &container, &short_name)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->CreateUser(cn, container, short_name);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_CreateGroup_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *cn, *short_name, *container;
       if (!PyArg_ParseTuple(args, "Osss", &obj, &cn, &container, &short_name)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->CreateGroup(cn, container, short_name);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_DeleteDN_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *dn;
       if (!PyArg_ParseTuple(args, "Os", &obj, &dn)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->DeleteDN(dn);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_CreateOU_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *ou;
       if (!PyArg_ParseTuple(args, "Os", &obj, &ou)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->CreateOU(ou);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_EnableUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->EnableUser(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_DisableUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->DisableUser(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserDescription_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *dn, *descr;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &dn, &descr)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserDescription(dn, descr);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_changeUserPassword_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *old_password, *new_password;
       if (!PyArg_ParseTuple(args, "Osss", &obj, &user, &old_password, &new_password)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->changeUserPassword(user, old_password, new_password);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserPassword_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *password;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &password)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserPassword(user, password);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_checkUserPassword_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *password;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &password)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          return Py_BuildValue("N", PyBool_FromLong(ad->checkUserPassword(user, password)));
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
}

static PyObject *wrapper_setUserDialinAllowed_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserDialinAllowed(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserDialinDisabled_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserDialinDisabled(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserSN_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *sn;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &sn)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserSN(user, sn);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserInitials_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *initials;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &initials)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserInitials(user, initials);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserGivenName_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *givenName;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &givenName)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserGivenName(user, givenName);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserDisplayName_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *displayName;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &displayName)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserDisplayName(user, displayName);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserRoomNumber_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *roomNum;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &roomNum)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserRoomNumber(user, roomNum);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserAddress_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *streetAddress;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &streetAddress)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserAddress(user, streetAddress);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserInfo_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *info;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &info)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserInfo(user, info);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserTitle_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *title;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &title)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserTitle(user, title);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserDepartment_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *department;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &department)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserDepartment(user, department);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserCompany_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *company;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &company)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserCompany(user, company);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserPhone_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *phone;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &phone)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserPhone(user, phone);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setUserIpAddress_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user, *ip;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &ip)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->setUserIpAddress(user, ip);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_setObjectAttribute_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *object, *attr;
       PyObject *listObj;

       if (!PyArg_ParseTuple(args, "OssO!", &obj, &object, &attr, &PyList_Type, &listObj)) return NULL;

       vector<string> values;
       for (unsigned int i = 0; i < PyList_Size(listObj); ++i) {
           PyObject *strObj = PyList_GetItem(listObj, i);
           string item = PyString_AsString(strObj);
           values.push_back(item);
       }

       adclient *ad = convert_ad(obj);
       try {
          ad->setObjectAttribute(object, attr, values);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject *wrapper_clearObjectAttribute_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *object, *attr;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &object, &attr)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->clearObjectAttribute(object, attr);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject * wrapper_UnLockUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       if (!PyArg_ParseTuple(args, "Os", &obj, &user)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->UnLockUser(user);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject * wrapper_MoveUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       char *new_container;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &user, &new_container)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->MoveUser(user, new_container);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject * wrapper_MoveObject_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *object;
       char *new_container;
       if (!PyArg_ParseTuple(args, "Oss", &obj, &object, &new_container)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->MoveObject(object, new_container);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyObject * wrapper_RenameUser_adclient(PyObject *self, PyObject *args) {
       PyObject *obj;
       char *user;
       char *shortname;
       char *cn;
       if (!PyArg_ParseTuple(args, "Osss", &obj, &user, &shortname, &cn)) return NULL;
       adclient *ad = convert_ad(obj);
       try {
          ad->RenameUser(user, shortname, cn);
       }
       catch(ADSearchException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADSearchError, ex.msg.c_str());
            return NULL;
       }
       catch(ADOperationalException& ex) {
            error_num = ex.code;
            PyErr_SetString(ADOperationalError, ex.msg.c_str());
            return NULL;
       }
       Py_INCREF(Py_None);
       return Py_None;
}

static PyMethodDef adclient_methods[] = {
       { "new_adclient", wrapper_new_adclient, 1 },
       { "login_adclient", wrapper_login_adclient, 1 },
       { "searchDN_adclient", wrapper_searchDN_adclient, 1},
       { "search_adclient", wrapper_search_adclient, 1},
       { "getUserGroups_adclient", wrapper_getUserGroups_adclient, 1 },
       { "getUsersInGroup_adclient", wrapper_getUsersInGroup_adclient, 1},
       { "getUserControls_adclient", wrapper_getUserControls_adclient, 1 },
       { "groupAddUser_adclient", wrapper_groupAddUser_adclient, 1 },
       { "groupRemoveUser_adclient", wrapper_groupRemoveUser_adclient, 1 },
       { "ifDialinUser_adclient", wrapper_ifDialinUser_adclient, 1 },
       { "getDialinUsers_adclient", wrapper_getDialinUsers_adclient, 1 },
       { "getDisabledUsers_adclient", wrapper_getDisabledUsers_adclient, 1 },
       { "getObjectDN_adclient", wrapper_getObjectDN_adclient, 1 },
       { "ifUserDisabled_adclient", wrapper_ifUserDisabled_adclient, 1 },
       { "getOUs_adclient", wrapper_getOUs_adclient, 1 },
       { "getGroupsInOU_adclient", wrapper_getGroupsInOU_adclient, 1},
       { "getComputersInOU_adclient", wrapper_getComputersInOU_adclient, 1},
       { "getOUsInOU_adclient", wrapper_getOUsInOU_adclient, 1},
       { "getUsersInOU_adclient", wrapper_getUsersInOU_adclient, 1 },
       { "getGroups_adclient", wrapper_getGroups_adclient, 1 },
       { "getUsers_adclient", wrapper_getUsers_adclient, 1 },
       { "getUserDisplayName_adclient", wrapper_getUserDisplayName_adclient, 1 },
       { "getUserIpAddress_adclient", wrapper_getUserIpAddress_adclient, 1 },
       { "getObjectAttribute_adclient", wrapper_getObjectAttribute_adclient, 1 },
       { "getObjectAttributes_adclient", wrapper_getObjectAttributes_adclient, 1 },
       { "CreateUser_adclient", wrapper_CreateUser_adclient, 1 },
       { "CreateComputer_adclient", wrapper_CreateComputer_adclient, 1 },
       { "CreateGroup_adclient", wrapper_CreateGroup_adclient, 1 },
       { "DeleteDN_adclient", wrapper_DeleteDN_adclient, 1 },
       { "CreateOU_adclient", wrapper_CreateOU_adclient, 1 },
       { "EnableUser_adclient", wrapper_EnableUser_adclient, 1 },
       { "DisableUser_adclient", wrapper_DisableUser_adclient, 1 },
       { "setUserDescription_adclient", wrapper_setUserDescription_adclient, 1 },
       { "changeUserPassword_adclient", wrapper_changeUserPassword_adclient, 1 },
       { "setUserPassword_adclient", wrapper_setUserPassword_adclient, 1 },
       { "checkUserPassword_adclient", wrapper_checkUserPassword_adclient, 1 },
       { "setUserDialinAllowed_adclient", wrapper_setUserDialinAllowed_adclient, 1 },
       { "setUserDialinDisabled_adclient", wrapper_setUserDialinDisabled_adclient, 1 },
       { "setUserSN_adclient", wrapper_setUserSN_adclient, 1 },
       { "setUserInitials_adclient", wrapper_setUserInitials_adclient, 1 },
       { "setUserGivenName_adclient", wrapper_setUserGivenName_adclient, 1 },
       { "setUserDisplayName_adclient", wrapper_setUserDisplayName_adclient, 1 },
       { "setUserRoomNumber_adclient", wrapper_setUserRoomNumber_adclient, 1 },
       { "setUserAddress_adclient", wrapper_setUserAddress_adclient, 1 },
       { "setUserInfo_adclient", wrapper_setUserInfo_adclient, 1 },
       { "setUserTitle_adclient", wrapper_setUserTitle_adclient, 1 },
       { "setUserDepartment_adclient", wrapper_setUserDepartment_adclient, 1 },
       { "setUserCompany_adclient", wrapper_setUserCompany_adclient, 1 },
       { "setUserPhone_adclient", wrapper_setUserPhone_adclient, 1 },
       { "setUserIpAddress_adclient", wrapper_setUserIpAddress_adclient, 1 },
       { "clearObjectAttribute_adclient", wrapper_clearObjectAttribute_adclient, 1 },
       { "setObjectAttribute_adclient", wrapper_setObjectAttribute_adclient, 1 },
       { "UnLockUser_adclient", wrapper_UnLockUser_adclient, 1 },
       { "MoveUser_adclient", wrapper_MoveUser_adclient, 1 },
       { "MoveObject_adclient", wrapper_MoveObject_adclient, 1 },
       { "RenameUser_adclient", wrapper_RenameUser_adclient, 1 },
       { "ifDNExists_adclient", wrapper_ifDNExists_adclient, 1 },
       { "binded_uri_adclient", wrapper_binded_uri_adclient, 1},
       { "search_base_adclient", wrapper_search_base_adclient, 1},
       { "login_method_adclient", wrapper_login_method_adclient, 1},
       { "bind_method_adclient", wrapper_bind_method_adclient, 1},
       { "get_error_num", wrapper_get_error_num, 1 },
       { "int2ip", wrapper_int2ip, 1 },
       { "domain2dn", wrapper_domain2dn, 1 },
       { "decodeSID", wrapper_decodeSID, 1 },
       { "FileTimeToPOSIX", wrapper_FileTimeToPOSIX, 1 },
       { "get_ldap_servers", wrapper_get_ldap_servers, 1 },
       { NULL, NULL }
};

PyMODINIT_FUNC
init_adclient(void) {
       PyObject *m;
       m = Py_InitModule("_adclient", adclient_methods);
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
       ADBindError = PyErr_NewException("ADBindError.error", NULL, NULL);
       ADSearchError = PyErr_NewException("ADSearchError.error", NULL, NULL);
       ADOperationalError = PyErr_NewException("ADOperationalError.error", NULL, NULL);
#pragma GCC diagnostic pop
       Py_INCREF(ADBindError);
       Py_INCREF(ADSearchError);
       Py_INCREF(ADOperationalError);
       PyModule_AddObject(m, "ADBindError", ADBindError);
       PyModule_AddObject(m, "ADSearchError", ADSearchError);
       PyModule_AddObject(m, "ADOperationalError", ADOperationalError);

       PyModule_AddIntMacro(m, AD_SUCCESS);
       PyModule_AddIntMacro(m, AD_LDAP_CONNECTION_ERROR);
       PyModule_AddIntMacro(m, AD_PARAMS_ERROR);
       PyModule_AddIntMacro(m, AD_SERVER_CONNECT_FAILURE);
       PyModule_AddIntMacro(m, AD_OBJECT_NOT_FOUND);
       PyModule_AddIntMacro(m, AD_ATTRIBUTE_ENTRY_NOT_FOUND);
       PyModule_AddIntMacro(m, AD_OU_SYNTAX_ERROR);

       PyModule_AddIntMacro(m, AD_SCOPE_BASE);
       PyModule_AddIntMacro(m, AD_SCOPE_ONELEVEL);
       PyModule_AddIntMacro(m, AD_SCOPE_SUBTREE);
}
