# python-exec -- test fixtures
# (c) 2021 Michał Górny
# Licensed under the terms of the 2-clause BSD license.

import os
import pathlib
import shutil
import subprocess

import pytest


for x in ('print-bufsiz', 'python-exec2', 'python-exec2c'):
    if not os.access(f'test/bin/{x}', os.X_OK):
        raise RuntimeError('Please run make check to build test executables')


def python_impls():
    out = subprocess.check_output(['test/bin/python-exec2c',
                                   '--list-implementations'])
    for x in out.decode().split():
        if shutil.which(x) is not None:
            yield x


PYTHON_IMPLS = list(reversed(list(python_impls())))


@pytest.fixture
def test_dir():
    td = pathlib.Path('test/data')
    shutil.rmtree(td, ignore_errors=True)
    os.makedirs(td, exist_ok=True)
    yield td


@pytest.fixture(scope='session', params=PYTHON_IMPLS)
def every_python(request):
    """Return all Python interpreters that are supported and installed."""
    yield request.param



@pytest.fixture(scope='session', params=PYTHON_IMPLS[:-1])
def nonbest_python(request):
    """Return all Python interpreters except the best one."""
    yield request.param


@pytest.fixture(scope='session', params=[os.symlink, shutil.copy])
def copy_method(request):
    """Parametrize on symlinking and copying."""
    yield request.param
