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
    ap.add_argument("schema_files", type=str, nargs='*',
                    help="preparsed schema file or list of additional schema files/directories")
    ap.add_argument('-d', '--duplicates', help="Only output properties with more than one type", action="store_true")
    ap.add_argument('-v', '--verbose', help="Additional search path for references", action="store_true")
    ap.add_argument('-V', '--version', help="Print version number",
                    action="version", version=dtschema.__version__)
    args = ap.parse_args()

    dtval = dtschema.DTValidator(args.schema_files)
    props = dtval.property_get_all()

    if args.duplicates:
        tmp_props = {}
        for k, v in props.items():
            if len(v) > 1:
                tmp_props[k] = v

        props = tmp_props

    if args.verbose:
        prop_types = props
    else:
        prop_types = {}
        for k, v in props.items():
            prop_types[k] = []
            for l in v:
                if 'type' in l:
                    prop_types[k] += [l['type']]

    try:
        pprint.pprint(prop_types, compact=True)
        # flush output here to force SIGPIPE to be triggered
        # while inside this try block.
        sys.stdout.flush()
    except BrokenPipeError:
        # Python flushes standard streams on exit; redirect remaining output
        # to devnull to avoid another BrokenPipeError at shutdown
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        sys.exit(1)  # Python exits with error code 1 on EPIPE
