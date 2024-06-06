import subprocess
from .brishmod import CmdResult
import os


def brishz(cmd_array, stdin=""):
    "Uses (and needs) BrishGarden via 'brishzq.zsh', thus costing the caller possible startup costs."

    sp = subprocess.run(
    ["/usr/bin/env", "brishz_in=MAGIC_READ_STDIN", "brishzq.zsh", *cmd_array],
    shell=False,
    cwd=os.getcwd(),
    text=True,
    executable=None,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    input=stdin
    )

    return CmdResult(sp.returncode, sp.stdout, sp.stderr, cmd_array, stdin)

## @personal
def isNight():
    return bool(os.environ.get("NIGHTDIR", False))

def brishzn(*args, **kwargs):
    if isNight():
        return brishz(*args, **kwargs)
    else:
        # return None
        return CmdResult(127, "", "night.sh not found", "NA", "NA")
##
