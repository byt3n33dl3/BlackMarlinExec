# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2018 Linaro Ltd.
# Copyright 2018-2023 Arm Ltd.
# Python library for Devicetree schema validation
import os
import re
import pprint

# We use a lot of regex's in schema and exceeding the cache size has noticeable
# peformance impact.
re._MAXCACHE = 2048


class sized_int(int):
    def __new__(cls, value, *args, **kwargs):
        return int.__new__(cls, value)

    def __init__(self, value, size=32):
        self.size = size


def _value_is_type(subschema, key, type):
    if key not in subschema:
        return False

    if isinstance(subschema[key], list):
        val = subschema[key][0]
    else:
        val = subschema[key]

    return isinstance(val, type)


def _is_int_schema(subschema):
    for match in ['const', 'enum', 'minimum', 'maximum']:
        if _value_is_type(subschema, match, int):
            return True

    return False


def _is_string_schema(subschema):
    for match in ['const', 'enum', 'pattern']:
        if _value_is_type(subschema, match, str):
            return True

    return False


def extract_node_compatibles(schema):
    if not isinstance(schema, dict):
        return set()

    compatible_list = set()

    for l in item_generator(schema, 'enum'):
        if isinstance(l[0], str):
            compatible_list.update(l)

    for l in item_generator(schema, 'const'):
        compatible_list.update([str(l)])

    for l in item_generator(schema, 'pattern'):
        compatible_list.update([l])

    return compatible_list


def extract_compatibles(schema):
    if not isinstance(schema, dict):
        return set()

    compatible_list = set()
    for sch in item_generator(schema, 'compatible'):
        compatible_list.update(extract_node_compatibles(sch))

    return compatible_list


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


def _get_array_range(subschema):
    if isinstance(subschema, list):
        if len(subschema) != 1:
            return (0, 0)
        subschema = subschema[0]
    if 'items' in subschema and isinstance(subschema['items'], list):
        max = len(subschema['items'])
        min = subschema.get('minItems', max)
    else:
        min = subschema.get('minItems', 1)
        max = subschema.get('maxItems', subschema.get('minItems', 0))

    return (min, max)


def format_error(filename, error, prefix="", nodename=None, verbose=False):
    src = prefix + os.path.abspath(filename) + ':'

    if hasattr(error, 'linecol') and error.linecol[0] >= 0:
        src = src + '%i:%i: ' % (error.linecol[0]+1, error.linecol[1]+1)
    else:
        src += ' '

    if nodename is not None:
        src += nodename + ': '

    if error.absolute_path:
        for path in error.absolute_path:
            src += str(path) + ":"
        src += ' '

    #print(error.__dict__)
    if verbose:
        msg = str(error)
    elif not error.schema_path:
        msg = error.message
    elif error.context:
        # An error on a conditional will have context with sub-errors
        msg = "'" + error.schema_path[-1] + "' conditional failed, one must be fixed:"

        for suberror in sorted(error.context, key=lambda e: e.path):
            if suberror.context:
                msg += '\n' + format_error(filename, suberror, prefix=prefix+"\t", nodename=nodename, verbose=verbose)
            elif suberror.message not in msg:
                msg += '\n' + prefix + '\t' + suberror.message
                if hasattr(suberror, 'note') and suberror.note and suberror.note != error.note:
                    msg += '\n\t\t' + prefix + 'hint: ' + suberror.note

    elif error.schema_path[-1] == 'oneOf':
        msg = 'More than one condition true in oneOf schema:\n\t' + \
            '\t'.join(pprint.pformat(error.schema, width=72).splitlines(True))

    else:
        msg = error.message

    if hasattr(error, 'note') and error.note:
        msg += '\n\t' + prefix + 'hint: ' + error.note

    if hasattr(error, 'schema_file') and error.schema_file:
        msg += '\n\t' + prefix + 'from schema $id: ' + error.schema_file

    return src + msg
