#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2018 Linaro Ltd.
# Copyright 2018 Arm Ltd.

import os
import argparse

import ruamel.yaml

yaml = ruamel.yaml.YAML()


def item_generator(json_input, lookup_key):
    if isinstance(json_input, dict):
        for k, v in json_input.items():
            if k == lookup_key:
                yield v
            else:
                for child_val in item_generator(v, lookup_key):
                    yield child_val
    elif isinstance(json_input, list):
        for item in json_input:
            for item_val in item_generator(item, lookup_key):
                yield item_val


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("yamlfile", type=str,
                    help="Filename of YAML encoded schema input file")
    args = ap.parse_args()

    schema_path = os.getcwd()

    testtree = yaml.load(open(args.yamlfile, encoding='utf-8').read())

    compatible_list = []
    for l in item_generator(testtree['properties']['compatible'], 'enum'):
        for _l in l:
            if _l not in compatible_list:
                compatible_list.append(_l)

    for c in compatible_list:
        print(c)
