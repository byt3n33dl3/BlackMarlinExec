#!/usr/bin/env python
import sys
import platform

Help("""
Type: 'scons' to build libadclient library
      'scons install [prefix=/path]' to install libadclient library and header file [to /path/{include,lib}]
      'scons -c install [prefix=/path]' to uninstall libadclient library and header file [from /path/{include,lib}]
""")

ldap_test_source_file = """
#include <ldap.h>
int main() {
    LDAPDN exp_dn;
    ldap_str2dn("test", &exp_dn, LDAP_DN_FORMAT_LDAPV3);
    return 0;
}
"""

openldap_test_source_file = """
#include <ldap.h>
#include <string.h>
int main() {
    return strcmp( LDAP_VENDOR_NAME,"OpenLDAP");
}
"""

sunldap_test_source_file = """
#include <ldap.h>
#include <string.h>
int main() {
    return strcmp( LDAP_VENDOR_NAME,"Sun Microsystems Inc.");
}
"""

def sasl_mechanisms_source_file(meh):
    return """
#include <sasl/sasl.h>
#include <cstdlib>
#include <string>

static sasl_callback_t client_interactions[] = {{
  {{ SASL_CB_GETREALM, NULL, NULL }},
  {{ SASL_CB_USER, NULL, NULL }},
  {{ SASL_CB_AUTHNAME, NULL, NULL }},
  {{ SASL_CB_PASS, NULL, NULL }},
  {{ SASL_CB_LIST_END, NULL, NULL }}
}};

int main() {{
  std::string method = "{}";
  if (sasl_client_init(client_interactions) != SASL_OK) return 1;

  sasl_conn_t *conn;
  if (sasl_client_new("rcmd", "localhost", NULL, NULL, NULL, 0, &conn) != SASL_OK) return 1;

  const char *mechlist = NULL;
  if (sasl_listmech(conn, NULL, ",", ",", ",", &mechlist, NULL, NULL) == SASL_OK)
     return (std::string(mechlist).find("," + method + ",") == std::string::npos);

  return 1;
}}
""".format(meh)

LibPath = ['/usr/lib', '/usr/local/lib']
IncludePath = ['.', '/usr/local/include', '/usr/include']

env = Environment(CCFLAGS = " -O0 -g -Wall ", LIBPATH = LibPath, CPPPATH = IncludePath)

PREFIX=ARGUMENTS.get('prefix', '/usr/local')

IGNORE = False
ignore = ['--help', '-h', '-c']
for arg in ignore:
    if arg in sys.argv:
       IGNORE = True
       break

def checkLdapVersion(context):
   context.Message('Checking for new LDAPDN definition... ')
   result = context.TryLink(ldap_test_source_file, ".cpp")
   context.Result(result)
   return result

def checkOpenLdap(context):
   context.Message('Checking for OPENLDAP definition... ')
   result = context.TryRun(openldap_test_source_file, ".cpp")
   context.Result(result[0])
   return result[0]

def checkSundap(context):
   context.Message('Checking for SunLDAP definition... ')
   result = context.TryRun(sunldap_test_source_file, ".cpp")
   context.Result(result[0])
   return result[0]

def checkSASL_DIGEST_MD5(context):
   context.Message('Checking for DIGEST-MD5 mechanisms in sasl ... ')
   result = context.TryRun(sasl_mechanisms_source_file("DIGEST-MD5"), ".cpp")
   context.Result(result[0])
   return result[0]

def checkSASL_GSSAPI(context):
   context.Message('Checking for GSSAPI mechanisms in sasl ... ')
   result = context.TryRun(sasl_mechanisms_source_file("GSSAPI"), ".cpp")
   context.Result(result[0])
   return result[0]

krb5_sources = []

if not IGNORE:
   conf = Configure(env, custom_tests = {'checkLdapVersion' : checkLdapVersion,
                                          'openldap' : checkOpenLdap, 'sunldap':checkSundap,
                                          'sasl_gssapi': checkSASL_GSSAPI, 'sasl_digestmd5': checkSASL_DIGEST_MD5})
   check_c_funcs = ['strdup' , 'strlen', 'strcmp', 'memset', 'bzero']
   for func in check_c_funcs:
       if not conf.CheckFunc(func):
          print("Failed.")
          Exit(1)

   check_c_headers = ['ldap.h', 'sasl/sasl.h']
   for header in check_c_headers:
       if not conf.CheckCHeader(header):
          print("Failed.")
          Exit(1)

   check_cxx_headers = ['string', 'vector']
   for header in check_cxx_headers:
       if not conf.CheckCXXHeader(header):
          print("Failed.")
          Exit(1)

   #env.Append(LIBS=["ldap", "sasl2", "resolv", "stdc++"])
   check_libs = ['ldap', 'sasl2', 'resolv', 'stdc++']
   for lib in check_libs:
       if not conf.CheckLib(lib):
          print("Failed.")
          Exit(1)

   if not conf.sasl_digestmd5():
       print("Failed.")
       Exit(1)

   if conf.CheckCHeader("krb5.h") and conf.CheckLib("krb5") and conf.sasl_gssapi():
       env.Append(CCFLAGS=" -DKRB5 ")
       krb5_sources = ["adclient_krb.cpp"]

   if conf.openldap():
      env.Append(CCFLAGS=" -DOPENLDAP ")
   elif conf.sunldap():
      env.Append(CCFLAGS=" -DSUNLDAP ")
   if not conf.checkLdapVersion():
      env.Append(CCFLAGS=" -DLDAP21 ")
   env = conf.Finish()

if platform.system() == "Darwin" and platform.mac_ver()[0] >= '10.11':
    # suppress OpenDirectory Framework warnings for OSX >= 10.11
    env.Append(CCFLAGS=" -Wno-deprecated ")

libadclient_target = env.SharedLibrary('adclient', ['adclient.cpp', 'adclient_sasl.cpp'] + krb5_sources)

lib_install_target = env.Install(PREFIX+'/lib', libadclient_target)
header_install_target = env.Install(PREFIX+'/include', 'adclient.h')

env.Alias('install', lib_install_target)
env.Alias('install', header_install_target)
