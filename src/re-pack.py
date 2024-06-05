#!/usr/bin/env python

import argparse
import os
import shutil
import zipfile

from pathlib import Path, PurePath


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("package_cache",
                      type=Path,
                      help="Top .pipx_package_cache directory")
    argp.add_argument("out_dir",
                      type=Path,
                      help="Directory to place repacked wheels into")
    args = argp.parse_args()

    packages = {}
    for dirpath, dirs, files in os.walk(args.package_cache):
        dirpath_p = Path(dirpath)
        for f in files:
            if not f.endswith(".whl"):
                continue

            package, version, _, _, _ = f.split("-")
            packages[(package, version)] = dirpath_p / f

    for (package, version), path in packages.items():
        out_path = args.out_dir / f"{package}-{version}-py3-none-any.whl"
        with (zipfile.ZipFile(path) as in_zip,
              zipfile.ZipFile(out_path, "w") as out_zip):
            for in_zipinfo in in_zip.infolist():
                if in_zipinfo.is_dir():
                    continue
                sub_path = tuple(in_zipinfo.filename.split("/"))
                out_zipinfo = zipfile.ZipInfo(in_zipinfo.filename)
                out_zipinfo.external_attr = in_zipinfo.external_attr

                if sub_path[0].endswith(".dist-info"):
                    if sub_path[1] in ("WHEEL", "entry_points.txt"):
                        pass
                    elif sub_path[1] == "METADATA":
                        with (in_zip.open(in_zipinfo) as in_file,
                              out_zip.open(out_zipinfo, "w") as out_file):
                            out_file.write(in_file.read().split(b"\n\n")[0])
                        continue
                    elif sub_path[1] == "RECORD":
                        with out_zip.open(out_zipinfo, "w") as out_file:
                            pass
                        continue
                    else:
                        continue
                elif sub_path[0].endswith(".data") and sub_path[1] == "scripts":
                    if sub_path[2] in ("aws", "cloudtoken", "get_gprof",
                                       "get_objgraph", "undill"):
                        with out_zip.open(out_zipinfo, "w") as out_file:
                            out_file.write(b"#!/bin/sh")
                    continue
                elif sub_path == ("packaging", "__init__.py"):
                    pass
                elif sub_path == ("requests", "__version__.py"):
                    pass
                elif package == "pycowsay":
                    pass
                else:
                    continue

                with (in_zip.open(in_zipinfo) as in_file,
                      out_zip.open(out_zipinfo, "w") as out_file):
                    shutil.copyfileobj(in_file, out_file)

            if package == "certifi":
                with out_zip.open("certifi/__init__.py", "w") as out_file:
                    out_file.write(f'__version__ = "{version}"\n'.encode())
            elif package == "requests":
                with out_zip.open(f"requests/__init__.py", "w") as out_file:
                    out_file.write(b"from .__version__ import __version__\n")

if __name__ == "__main__":
    main()
