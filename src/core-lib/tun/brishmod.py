try:
    # Dev imports
    # from IPython import embed
    # importing this takes quite a bit of time
    #   `time2 python -c 'from IPython import embed'`
    from icecream import ic

    pass
except ImportError:
    def ic(*args, **kwargs):
        pass

    def embed(*args, **kwargs):
        print("IPython not available.")

    pass


import sys
import time
import os
import shutil
import tempfile
from collections.abc import Iterable
from typing import Union, Any
import ast
from string import Formatter
import uuid
import random
from subprocess import Popen, PIPE, STDOUT
import pathlib
from dataclasses import dataclass
import inspect
from icecream import ic

# http://docs.python.org/library/threading.html#rlock-objects
from threading import RLock


def idem(x):
    return x


def boolsh(some_bool):
    if some_bool:
        return "y"
    else:
        return ""

def bool_from_str(some_bool):
    if isinstance(some_bool, str) and some_bool.lower() in ("", "0", "n", "no", "false"):
        return False
    else:
        return bool(some_bool)


class NonzeroBrishException(Exception):
    pass

@dataclass(frozen=True)
class CmdResult:
    retcode: int
    out: str
    err: str
    cmd: Any # Union[str, Iterable[str]]
    cmd_stdin: str # Union[str, None]

    @property
    def outrs(self):
        """ out.rstrip('\\n') """
        return self.out.rstrip("\n")

    @property
    def summary(self):
        return self.retcode, self.out, self.err

    @property
    def outerr(self):
        return self.out + self.err

    @property
    def longstr(self):
        r = ""
        if self.cmd_stdin:
            r += f"""\ncmd_stdin:\n{self.cmd_stdin}"""
        r += f"""\ncmd: {self.cmd}"""
        if True or self.out:
            r += f"""\nstdout:\n{self.out}"""
        if self.err:
            r += f"""\nstderr:\n{self.err}"""
        if not self:
            r += f"""\nreturn code: {self.retcode}"""
        return r + "\n"

    def print(self, *args, **kwargs):
        print(self.longstr, *args, **kwargs, flush=True)

    def __iter__(self):
        # return iter(self.toTuple())
        return iter(self.outrs.split("\n"))

    def iter0(self):
        return iter(self.out.rstrip("\x00").split("\x00"))

    # def __getitem__(self, index):
    #     return self.toTuple()[index]

    def __str__(self):
        return self.outrs

    def __bool__(self):
        return self.retcode == 0

    @property
    def assert_zero(self):
        if self.retcode == 0:
            return self
        else:
            raise NonzeroBrishException(f"retcode={self.retcode}, stderr:\n{self.err}")

class UninitializedBrishException(Exception):
    pass

class Brish:
    """Brish is a bridge between Python and an interpreter. The interpreter needs to adhere to the Brish protocol. A zsh interpreter is provided, and is the default. Threadsafe."""

    # MARKER = '\x00BRISH_MARKER'
    MARKER = "\x00"

    def __init__(self, defaultShell=None, boot_cmd=None, server_count=1, delayed_init=False, **kwargs):
        self.lock = RLock()
        if boot_cmd:
            self.boot_cmd = _shared_brish.zstring(boot_cmd, getframe=2)
        else:
            self.boot_cmd = boot_cmd

        self.defaultShell = defaultShell or [
            str(pathlib.Path(__file__).parent / "brish2.zsh"),
            "--",
            "BR" + "I" * 2048 + "SH",
        ]  # Reserve big argv for `insubshell`
        self.lastShell = self.defaultShell
        self.last_server_count = server_count
        self.p = None
        self.delayed_init = delayed_init
        if not self.delayed_init:
            self.init(**kwargs)

    def init(self,
             shell=None,
             server_count=None,
             decoding_errors="backslashreplace",
             # https://docs.python.org/3/library/codecs.html#codec-base-classes
             encoding="utf-8",):
        with self.lock:
            if not server_count:
                server_count = self.last_server_count

            if shell is None:
                shell = self.defaultShell

            self.lastShell = shell
            self.last_server_count = server_count

            tmpdir = tempfile.mkdtemp()

            assert server_count >= 1
            self.locks = [RLock() for i in range(server_count)]
            brish_stdin_paths = [
                os.path.join(tmpdir, f"brish_{i}_stdin") for i in range(server_count)
            ]
            brish_stdout_paths = [
                os.path.join(tmpdir, f"brish_{i}_stdout") for i in range(server_count)
            ]
            brish_stderr_paths = [
                os.path.join(tmpdir, f"brish_{i}_stderr") for i in range(server_count)
            ]
            brish_stdins = [os.mkfifo(p) for p in brish_stdin_paths]
            brish_stdouts = [os.mkfifo(p) for p in brish_stdout_paths]
            brish_stderrs = [os.mkfifo(p) for p in brish_stderr_paths]

            self.p = Popen(
                shell,
                stdin=PIPE,
                stdout=PIPE,
                stderr=PIPE,
                env=dict(os.environ,),
                text=True,
                errors=decoding_errors, # escape invalid utf-8 bytes
                encoding=encoding,
            )
            BRISH_STDIN = "\n".join(brish_stdin_paths)
            BRISH_STDOUT = "\n".join(brish_stdout_paths)
            BRISH_STDERR = "\n".join(brish_stderr_paths)
            print(
                BRISH_STDIN
                + self.MARKER
                + BRISH_STDOUT
                + self.MARKER
                + BRISH_STDERR
                + self.MARKER,
                file=self.p.stdin,
                flush=True,
            )
            self.p.tmpdir = tmpdir
            self.p.server_count = server_count
            self.p.free_server_count = server_count
            self.p.brish_stdin_paths = brish_stdin_paths
            self.p.brish_stdout_paths = brish_stdout_paths
            self.p.brish_stderr_paths = brish_stderr_paths
            self.p.brish_stdins = [open(p, "w", errors='strict', encoding=encoding,) for p in self.p.brish_stdin_paths]
            self.p.brish_stdouts = [open(p, "r", errors=decoding_errors, encoding=encoding) for p in self.p.brish_stdout_paths]
            self.p.brish_stderrs = [open(p, "r", errors=decoding_errors, encoding=encoding,) for p in self.p.brish_stderr_paths]

            if self.boot_cmd is not None:
                return [
                    self.send_cmd(self.boot_cmd, fork=False, server_index=i)
                    for i in range(server_count)
                ]

    def restart(self):
        with self.lock:
            self.cleanup()
            self.init(shell=self.lastShell, server_count=self.last_server_count)

    def zsh_quote(self, obj, use_shared_instance=True, retry_count=0, retry_limit=10):
        if obj is None:
            return ""

        if (
            use_shared_instance
        ):  # protects against accidentally reading output from previously running processes (background jobs)
            # @perf perhaps using a specialized routine might be faster, or just calling =zsh -f=
            self = _shared_brish

        typ = type(obj)
        if typ is CmdResult:
            return self.zsh_quote(obj.outrs)
        elif not isinstance(obj, str) and isinstance(obj, Iterable):
            result = []
            for i in iter(obj):
                # zsh doesn't support nested arrays, so we str the inner object.
                result.append(self.zsh_quote(str(i)))
            return " ".join(result)
        else:
            res = self.send_cmd(
                'print -rn -- "${(q+@)brish_stdin}"', cmd_stdin=str(obj)
            )
            if res:
                return res.out
            elif retry_count < retry_limit:
                return self.zsh_quote(
                    obj,
                    use_shared_instance=use_shared_instance,
                    retry_count=(retry_count + 1),
                    retry_limit=retry_limit,
                )
            else:
                raise Exception(
                    f"Quoting object {repr(obj)} failed; CmdResult:\n{res.longstr}"
                )

    def acquire_lock(self, server_index=None, lock_sleep=1):
        while True:
            if self.p is None:
                if self.delayed_init:
                    self.delayed_init = False
                    self.restart()
                else:
                    raise UninitializedBrishException("acquire_lock called with an uninitialized Brish")

            assert len(self.locks) >= 1
            current_p = self.p
            lock = None
            if server_index == None:
                acquired = False
                while acquired == False:
                    for i, c_lock in enumerate(self.locks):
                        acquired = c_lock.acquire(blocking=False)
                        # https://docs.python.org/3/library/threading.html#threading.Lock.acquire

                        if acquired == True:
                            lock = c_lock
                            server_index = i
                            break

                    if acquired == False:
                        if lock_sleep != None:
                            time.sleep(lock_sleep)
                        else:
                            break

                if acquired == False:
                    # server_index = random.randrange(self.p.server_count)
                    server_index = random.randrange(len(self.locks))

            if lock == None:
                try:
                    lock = self.locks[server_index]
                except:
                    ic(len(self.locks), server_index)
                    time.sleep(1)
                    continue

                lock.acquire()

            ##
            # f1 is f2 checks if two references are to the same object. Under the hood, this compares the results of id(f1) == id(f2) using the id builtin function, which returns a integer that's guaranteed unique to the object (but only within the object's lifetime).
            # Under CPython, this integer happens to be the address of the object in memory, though the docs mention you should pretend you don't know that (since other implementation may have other methods of generating the id).
            if self.p == current_p:
                # since we have acquired a lock, self.p can no longer change so there is no race condition anymore
                return lock, server_index
            else:
                lock.release()
                continue

    def send_cmd(
        self, cmd: str, cmd_stdin="", fork=False, server_index=None, lock_sleep=1
    ):
        lock, server_index = self.acquire_lock(
            server_index=server_index, lock_sleep=lock_sleep
        )
        try:
            self.p.free_server_count -= 1
            cmd_stdin = str(cmd_stdin)
            # assert  isinstance(cmd, str)
            if cmd == "%BRISH_RESTART":
                self.restart()
                return CmdResult(0, "Restarted succesfully.", "", cmd, cmd_stdin)
            if any(self.MARKER in input for input in (cmd, cmd_stdin)):
                return CmdResult(
                    9000,
                    "",
                    "Illegal input: Input contained the Brish marker (currently the NUL character).",
                    cmd,
                    cmd_stdin,
                )
            delim = self.MARKER + "\n"

            cmd_processed = (cmd
                             + self.MARKER
                             + cmd_stdin
                             + self.MARKER
                             + boolsh(fork)
                             + self.MARKER)

            ##
            # trying to open the stdin as binary. It didn't work, idk why.
            # cmd_processed = cmd_processed.encode()
            # self.p.brish_stdins[server_index].write(cmd_processed)
            ##
            print(
                cmd_processed,
                file=self.p.brish_stdins[server_index],
                flush=True,
            )
            ##

            stdout = ""
            # embed()
            for line in iter(self.p.brish_stdouts[server_index].readline, delim):
                stdout += line
            stdout = stdout[:-1]
            return_code = int(self.p.brish_stdouts[server_index].readline())
            stderr = ""
            for line in iter(self.p.brish_stderrs[server_index].readline, delim):
                stderr += line
            stderr = stderr[:-1]
            return CmdResult(return_code, stdout, stderr, cmd, cmd_stdin)
        finally:
            self.p.free_server_count += 1
            lock.release()

    def cleanup(self):
        with self.lock:
            if self.p is None:
                return
            locks = self.locks
            for lock in locks:
                lock.acquire()
            try:
                self.p.stdout.close()
                if self.p.stderr:
                    self.p.stderr.close()
                self.p.stdin.close()

                for p in self.p.brish_stdins:
                    p.close()

                for p in self.p.brish_stdouts:
                    p.close()

                for p in self.p.brish_stderrs:
                    p.close()

                shutil.rmtree(self.p.tmpdir)

                self.p.wait()
                self.p = None
                self.locks = []
            finally:
                for lock in locks:
                    lock.release()

    _conversions = {"a": ascii, "r": repr, "s": str, "e": idem, "b": boolsh}

    def zstring_old(self, template, locals_=None):
        # DEPRECATED
        if locals_ is None:
            previous_frame = sys._getframe(1)
            previous_frame_locals = previous_frame.f_locals
            locals_ = dict(previous_frame.f_globals, **previous_frame_locals)
            # https://stackoverflow.com/questions/1041639/get-a-dict-of-all-variables-currently-in-scope-and-their-values
            # We will still miss the closure variables.
        result = []
        parts = Formatter().parse(template)
        for part in parts:
            literal_text, field_name, format_spec, conversion = part
            # print(part)
            if literal_text:
                result.append(literal_text)
            if not field_name:
                continue
            value = eval(field_name, locals_)  # .__format__()
            if conversion:
                value = self._conversions[conversion](value)
            if format_spec:
                value = format(value, format_spec)
            else:
                value = str(value)
            if conversion != "e":
                value = self.zsh_quote(value)
            result.append(value)
        cmd = "".join(result)
        return cmd

    def zstring(self, template, locals_=None, getframe=1):
        if locals_ is None:
            try:
                previous_frame = sys._getframe(getframe)
                previous_frame_locals = previous_frame.f_locals
                locals_ = dict(previous_frame.f_globals, **previous_frame_locals)
                # https://stackoverflow.com/questions/1041639/get-a-dict-of-all-variables-currently-in-scope-and-their-values
                # We will still miss the closure variables.
            except:
                # Julia runs Python in an embedded mode with no stack frame.
                pass

        def asteval(astNode):
            if astNode is not None:
                return eval(
                    compile(ast.Expression(astNode), filename="<string>", mode="eval"),
                    locals_,
                )
            else:
                return None

        def eatFormat(format_spec, code):
            res = False
            if format_spec:
                flags = format_spec.split(":")
                res = code in flags
                format_spec = list(filter(lambda a: a != code, flags))
            return ":".join(format_spec), res

        p = ast.parse(f"f''' {template} '''")  # The whitespace is necessary
        result = []
        parts = p.body[0].value.values
        for part in parts:
            typ = type(part)
            if typ is ast.Constant or typ is ast.Str:
                result.append(part.s)  # part.value can also work in Py3.8
            elif typ is ast.FormattedValue:
                # print(part.__dict__)

                value = asteval(part.value)
                conversion = part.conversion
                if conversion >= 0:
                    # parser doesn't support custom conversions, but this code works:
                    conversion = chr(conversion)
                    value = self._conversions[conversion](value)
                # if part.format_spec:
                #     value = format(value, asteval(part.format_spec))
                # else:
                #     value = str(value)
                # if conversion != 'e':
                #     value = self.zsh_quote(value)
                # embed()

                format_spec = asteval(part.format_spec) or ""
                # print(f"orig format: {format_spec}")
                format_spec, fmt_eval = eatFormat(format_spec, "e")
                format_spec, fmt_bool = eatFormat(format_spec, "bool")
                # print(f"format: {format_spec}")
                if format_spec:
                    value = format(value, format_spec)
                if fmt_bool:
                    value = boolsh(value)

                if not fmt_eval:
                    value = self.zsh_quote(value)
                value = str(value)
                result.append(value)
        cmd = "".join(result)
        return cmd

    def z(self, template, locals_=None, getframe=2, *args, **kwargs):
        return self.send_cmd(
            self.zstring(template, locals_=locals_, getframe=getframe), *args, **kwargs
        )

    def z_print(self, *args, getframe=3, file=None, **kwargs):
        res = self.z(*args, getframe=getframe, **kwargs)

        print_opts = dict()
        if file is not None:
            print_opts['file'] = file

        print(res.outerr, end="", flush=True, **print_opts)
        return res

    def z_print_stderr(self, *args, getframe=4, **kwargs):
        ## tests:
        #: `rederr python -c 'from brish import * ; zpe("echo hi") ; zp("echo ic") ; zpe("echo woo")'`
        ##
        return self.z_print(*args, getframe=getframe, file=sys.stderr, **kwargs)

    # Aliases
    c = send_cmd
    zq = zsh_quote
    zp = z_print
    zpe = z_print_stderr


_shared_brish = (
    Brish(delayed_init=True)
)  # Any identifier of the form __spam (at least two leading underscores, at most one trailing underscore) is textually replaced with _classname__spam, so we can't use it in Brish if we use two underscores.
