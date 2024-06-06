import importlib
import gzip
import os
import hashlib
from io import BytesIO

_here = os.path.dirname(__file__)
_savefile = os.path.join(_here, "__wasm_python_bytes.py")


class ChecksumError(Exception):
    pass


def generate_checksum(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def fetch_file():
    print("wasm_runtime: getting wasm...\n")

    import requests

    r = requests.get(
        "https://github.com/vmware-labs/webassembly-language-runtimes/"
        "releases/download/python%2F3.11.3%2B20230428-7d1b259/python-3.11.3.wasm",
        stream=True,
    )
    full_length = int(r.headers["Content-Length"])
    i = 0
    io = BytesIO()

    for chunk in r.iter_content(1 << 9):  # pow(2, 9)
        i += len(chunk)
        io.write(chunk)
        print(f"(1/2) downloading wasm... {i/full_length*100:.2f}%", end="\r")

    value = io.getvalue()
    io.close()

    with open(_savefile, "wb") as f:
        f.write(f"WASM={gzip.compress(value)!r}".encode("utf-8"))

    print(
        "(1/2) 🐣 downloaded wasm to `wasm_runtime/__wasm_python_bytes.py` for inference"
    )
    print("(2/2) getting checksum...", end="\r")

    # Get the checksum (server)
    r = requests.get(
        "https://github.com/vmware-labs/webassembly-language-runtimes/"
        "releases/download/python%2F3.11.3%2B20230428-7d1b259/"
        "python-3.11.3.wasm.sha256sum"
    )

    print("(2/2) verifying checksum...", end="\r")

    server_checksum = r.text.split()[0]
    if server_checksum != generate_checksum(value):
        print()
        raise ChecksumError("Checksum unmatch!")

    print("(2/2) 🍕 checksum matched!  ")
    print("\nwasm_runtime: 🎉 done!")


def exists() -> bool:
    return os.path.exists(_savefile)


def get_runtime() -> bytes:
    if not exists():
        fetch_file()

    from . import __wasm_python_bytes  # type: ignore

    importlib.reload(__wasm_python_bytes)

    return gzip.decompress(__wasm_python_bytes.WASM)
