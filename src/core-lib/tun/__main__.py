from brish import *
from IPython import embed
from ipydex import IPS, ip_syshook, ST, activate_ips_on_exception, dirsearch
activate_ips_on_exception()

import IPython.lib.pretty
class NewPrettier(IPython.lib.pretty.RepresentationPrinter): 
     def pretty(self, obj): 
         if isinstance(obj, (str,)): 
             self.text(obj) 
         else: 
             super().pretty(obj) 
IPython.lib.pretty.RepresentationPrinter = NewPrettier

IPython.InteractiveShell.ast_node_interactivity = 'last_expr_or_assign'

w = "World!"
v = "$SOME_VAR"
t = True
f = False
b = "$NIGHTDIR"
a = 12

zs = bsh.zstring
print('wow hi')
embed()
