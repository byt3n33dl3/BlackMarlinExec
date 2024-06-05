#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2018 Linaro Ltd.
# Copyright 2018 Arm Ltd.

import sys
import argparse
import json

import ruamel.yaml
import dtschema


def main():
    ap = argparse.ArgumentParser(fromfile_prefix_chars='@',
        epilog='Arguments can also be passed in a file prefixed with a "@" character.')
    ap.add_argument("-o", "--outfile", type=str,
                    help="Filename of the processed schema")
    ap.add_argument("-j", "--json", help="Encode the processed schema in json",
                    action="store_true")
    ap.add_argument("schemas", nargs='*', type=str,
                    help="Names of directories, or YAML encoded schema files")
    ap.add_argument('-u', '--useronly', help="Only process user schemas", action="store_true")
    ap.add_argument('-V', '--version', help="Print version number",
                    action="version", version=dtschema.__version__)
    args = ap.parse_args()

    schemas = dtschema.DTValidator(args.schemas).schemas
    if not schemas:
        return -1

    if args.outfile:
        f = open(args.outfile, 'w', encoding='utf-8')
    else:
        f = sys.stdout

    if (args.json):
        json.dump(schemas, f, indent=4)
    else:
        yaml = ruamel.yaml.YAML(typ='safe')
        yaml.dump(schemas, f)
