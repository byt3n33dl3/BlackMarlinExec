#!/usr/bin/python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2022 Arm Ltd.

import argparse
import os
import sys
import pprint

import dtschema

strict = False

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("dtbfile", type=str, help="Schema directories and/or files")
    ap.add_argument('-s', '--schema', help="path to additional additional schema files")
    ap.add_argument('-V', '--version', help="Print version number",
                    action="version", version=dtschema.__version__)
    args = ap.parse_args()

    if not os.path.isfile(args.dtbfile):
        exit(1)

    if args.schema:
        schemas = [args.schema]
    else:
        schemas = []

    with open(args.dtbfile, 'rb') as f:
        dt = dtschema.DTValidator(schemas).decode_dtb(f.read())

    try:
        pprint.pprint(dt, compact=True)
        # flush output here to force SIGPIPE to be triggered
        # while inside this try block.
        sys.stdout.flush()
    except BrokenPipeError:
        # Python flushes standard streams on exit; redirect remaining output
        # to devnull to avoid another BrokenPipeError at shutdown
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        sys.exit(1)  # Python exits with error code 1 on EPIPE
