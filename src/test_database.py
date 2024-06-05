# (c) 2021 Michał Górny
# 2-clause BSD license

"""Tests for database support"""

import io
import unittest.mock

import pytest

from kuroneko.database import Database, Bug, DatabaseError


JSON_DATA = '''
{{"kuroneko-version": {version},
  "bugs": [
      {{"bug": 123456,
        "packages": [["dev-foo/bar"],
                     [">=dev-foo/foo-1", "<dev-foo/foo-1.7"]],
        "summary": "test bug",
        "severity": "C4",
        "created": "2021-01-01",
        "resolved": false}}
  ]}}'''

EXPECTED_BUGS = {
    123456: Bug(bug=123456,
                packages=[['dev-foo/bar'],
                          ['>=dev-foo/foo-1', '<dev-foo/foo-1.7']],
                summary='test bug',
                severity='C4',
                created='2021-01-01',
                resolved=False),
}


def test_load_database():
    db = Database()
    db.load(io.StringIO(
        JSON_DATA.format(version='"{}.{}"'.format(*db.SCHEMA_VERSION))))
    assert db.bugs == EXPECTED_BUGS


def test_round_robin():
    db = Database()
    db.bugs.update(EXPECTED_BUGS)
    data = io.StringIO()
    db.save(data)
    data.seek(0)
    db2 = Database()
    db2.load(data)
    assert db2.bugs == EXPECTED_BUGS


def test_no_magic():
    db = Database()
    with pytest.raises(DatabaseError):
        db.load(io.BytesIO(b'{"bugs": []}'))


@unittest.mock.patch('kuroneko.database.Database.SCHEMA_VERSION', (2, 1))
@pytest.mark.parametrize('version', ['"2.0"', '"2.2"'])
def test_version_good(version):
    db = Database()
    db.load(io.BytesIO(JSON_DATA.format(version=version).encode()))
    assert db.bugs == EXPECTED_BUGS


@unittest.mock.patch('kuroneko.database.Database.SCHEMA_VERSION', (2, 1))
@pytest.mark.parametrize('version', ['"1.0"', '"3.0"', '"2"', '2',
                                     '"2.2.s"', '"fnord"', '""', '2.1'])
def test_version_bad(version):
    db = Database()
    with pytest.raises(DatabaseError):
        db.load(io.BytesIO(JSON_DATA.format(version=version).encode()))
