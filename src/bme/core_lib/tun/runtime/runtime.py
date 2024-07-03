import os
import gzip
from contextlib import ExitStack
from functools import partial
from tempfile import NamedTemporaryFile
from dataclasses import dataclass
from typing import Iterable

from wasmtime import (
    Config,
    Engine,
    Linker,
    Module,
    Store,
    WasiConfig,
)

from ._get_runtime import _savefile, _here, get_runtime


@dataclass
class Result:
    stdout: str
    stderr: str
    memory_size: int
    data_len: int
    fuel_consumed: int


class WasmRuntime:
    def __init__(
        self, use_fuel: bool = False, fuel: int = 400_000_000, runtime_path: str = ""
    ):
        self.engine_cfg = Config()
        self.engine_cfg.consume_fuel = use_fuel
        self.engine_cfg.cache = True

        self.linker = Linker(Engine(self.engine_cfg))
        self.linker.define_wasi()

        if not runtime_path:
            runtime_path = _savefile

        self.python_module = Module(self.linker.engine, get_runtime())

        self.use_fuel = use_fuel
        self.fuel = fuel

    def _run_argv(self, argv: Iterable[str]):
        outfile, stderrfile = (
            NamedTemporaryFile(dir=_here),
            NamedTemporaryFile(dir=_here),
        )

        with ExitStack() as stack:
            stack.callback(partial(os.remove, outfile.name))
            stack.callback(partial(os.remove, stderrfile.name))

            self.config = WasiConfig()
            self.config.argv = argv
            self.config.stdout_file = outfile.name
            self.config.stderr_file = stderrfile.name

            self.store = Store(self.linker.engine, self.config)

            if self.use_fuel:
                self.store.add_fuel(self.fuel)

            self.store.set_wasi(self.config)
            self.instance = self.linker.instantiate(self.store, self.python_module)

            exports = self.instance.exports(self.store)
            start, mem = exports["_start"], exports["memory"]
            start(self.store)  # type: ignore

            return Result(
                stdout=outfile.read().decode("utf-8"),
                stderr=stderrfile.read().decode("utf-8"),
                memory_size=mem.size(self.store),  # type: ignore
                data_len=mem.data_len(self.store),  # type: ignore
                fuel_consumed=self.store.fuel_consumed() if self.use_fuel else 0,
            )
        
        return Result(
            stdout="",
            stderr="",
            memory_size=-1,
            data_len=-1,
            fuel_consumed=0
        )

    def exec(self, code: str) -> Result:
        byte_code = gzip.compress(code.encode("utf-8"))
        brackets = "{}"
        f_code = (
            f"""import gzip; exec(gzip.decompress({byte_code!r}).decode('utf-8'), {brackets}, {brackets})"""
        )
        return self._run_argv(("python", "-c", f_code))
