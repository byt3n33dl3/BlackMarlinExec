import os
from .brishz import *
from .brishmod import *
bsh = Brish(delayed_init=True, server_count=4)
z = bsh.z
zp = bsh.zp
zpe = bsh.zpe
zq = bsh.zsh_quote
zs = bsh.zstring
## @personal
def zn(*a, getframe=3, **kw):
    "Runs only if night.sh is installed"

    if isNight:
        return z(*a, **kw, getframe=getframe)
    else:
        # return None
        return CmdResult(127, "", "night.sh not found", "NA", "NA")
##
