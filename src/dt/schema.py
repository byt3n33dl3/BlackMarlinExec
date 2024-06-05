# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2018 Linaro Ltd.
# Copyright 2018-2023 Arm Ltd.
# Python library for Devicetree schema validation
import sys
import os
import ruamel.yaml
import re
import copy
import jsonschema

import dtschema

from jsonschema.exceptions import RefResolutionError

schema_base_url = "http://devicetree.org/"
schema_basedir = os.path.dirname(os.path.abspath(__file__))

rtyaml = ruamel.yaml.YAML(typ='rt')
rtyaml.allow_duplicate_keys = False
rtyaml.preserve_quotes = True

yaml = ruamel.yaml.YAML(typ='safe')
yaml.allow_duplicate_keys = False


def path_to_obj(tree, path):
    for pc in path:
        tree = tree[pc]
    return tree


def get_line_col(tree, path, obj=None):
    if isinstance(obj, ruamel.yaml.comments.CommentedBase):
        return obj.lc.line, obj.lc.col
    obj = path_to_obj(tree, path)
    if isinstance(obj, ruamel.yaml.comments.CommentedBase):
        return obj.lc.line, obj.lc.col
    if len(path) < 1:
        return -1, -1
    obj = path_to_obj(tree, list(path)[:-1])
    if isinstance(obj, ruamel.yaml.comments.CommentedBase):
        if path[-1] == '$nodename':
            return -1, -1
        return obj.lc.key(path[-1])
    return -1, -1


class DTSchema(dict):
    DtValidator = jsonschema.validators.extend(
        jsonschema.Draft201909Validator,
        format_checker=jsonschema.FormatChecker(),
        version='DT')

    def __init__(self, schema_file, line_numbers=False):
        self.paths = [(schema_base_url, schema_basedir + '/')]
        with open(schema_file, 'r', encoding='utf-8') as f:
            if line_numbers:
                schema = rtyaml.load(f.read())
            else:
                schema = yaml.load(f.read())

        self.filename = os.path.abspath(schema_file)

        id = schema['$id'].rstrip('#')
        match = re.search('(.*/schemas/)(.+)$', id)
        self.base_path = os.path.abspath(schema_file)[:-len(match[2])]

        super().__init__(schema)

    def http_handler(self, uri):
        '''Custom handler for http://devicetree.org references'''
        uri = uri.rstrip('#')
        for p in self.paths:
            filename = uri.replace(p[0], p[1])
            if not os.path.isfile(filename):
                continue
            with open(filename, 'r', encoding='utf-8') as f:
                return yaml.load(f.read())

        raise RefResolutionError('Error in referenced schema matching $id: ' + uri)

    def annotate_error(self, error, schema, path):
        error.note = None
        error.schema_file = None

        for e in error.context:
            self.annotate_error(e, schema, path + e.schema_path)

        scope = self.validator.ID_OF(schema)
        self.validator.resolver.push_scope(scope)
        ref_depth = 1

        for p in path:
            while p not in schema and '$ref' in schema and isinstance(schema['$ref'], str):
                ref = self.validator.resolver.resolve(schema['$ref'])
                schema = ref[1]
                self.validator.resolver.push_scope(ref[0])
                ref_depth += 1

            if '$id' in schema and isinstance(schema['$id'], str):
                error.schema_file = schema['$id']

            schema = schema[p]

            if isinstance(schema, dict):
                if 'description' in schema and isinstance(schema['description'], str):
                    error.note = schema['description']

        while ref_depth > 0:
            self.validator.resolver.pop_scope()
            ref_depth -= 1

        if isinstance(error.schema, dict) and 'description' in error.schema:
            error.note = error.schema['description']

    def iter_errors(self):
        self.resolver = jsonschema.RefResolver.from_schema(self,
                            handlers={'http': self.http_handler})
        meta_schema = self.resolver.resolve_from_url(self['$schema'])
        self.validator = self.DtValidator(meta_schema, resolver=self.resolver)

        for error in self.validator.iter_errors(self):
            scherr = jsonschema.exceptions.SchemaError.create_from(error)
            self.annotate_error(scherr, meta_schema, scherr.schema_path)
            scherr.linecol = get_line_col(self, scherr.path)
            yield scherr

    def is_valid(self, strict=False):
        ''' Check if schema passes validation against json-schema.org schema '''
        if strict:
            for error in self.iter_errors():
                raise error
        else:
            # Using the draft7 metaschema because 2019-09 with $recursiveRef seems broken
            # Probably fixed with referencing library
            for error in self.DtValidator(jsonschema.Draft7Validator.META_SCHEMA).iter_errors(self):
                scherr = jsonschema.exceptions.SchemaError.create_from(error)
                raise scherr

    def fixup(self):
        processed_schema = copy.deepcopy(dict(self))
        dtschema.fixups.fixup_schema(processed_schema)
        return processed_schema

    def _check_schema_refs(self, schema):
        if isinstance(schema, dict) and '$ref' in schema:
            self.resolver.resolve(schema['$ref'])
        elif isinstance(schema, dict):
            for k, v in schema.items():
                self._check_schema_refs(v)
        elif isinstance(schema, (list, tuple)):
            for i in range(len(schema)):
                self._check_schema_refs(schema[i])

    def check_schema_refs(self):
        id = self['$id'].rstrip('#')
        base1 = re.search('schemas/(.+)$', id)[1]
        base2 = self.filename.replace(self.filename[:-len(base1)], '')
        if not base1 == base2:
            print(f"{self.filename}: $id: Cannot determine base path from $id, relative path/filename doesn't match actual path or filename\n",
                  f"\t $id: {id}\n",
                  f"\tfile: {self.filename}",
                  file=sys.stderr)
            return

        self.paths = [
            (schema_base_url + 'schemas/', self.base_path),
            (schema_base_url + 'schemas/', schema_basedir + '/schemas/'),
        ]
        scope = self.validator.ID_OF(self)
        if scope:
            self.resolver.push_scope(scope)

        try:
            self._check_schema_refs(self)
        except jsonschema.RefResolutionError as exc:
            print(f"{self.filename}:\n{exc}", file=sys.stderr)
