# python-exec -- implementation selection tests
# (c) 2021 Michał Górny
# Licensed under the terms of the 2-clause BSD license.

import os
import subprocess

import pytest

from conftest import PYTHON_IMPLS


PROGRAM = '#!/bin/sh\necho {python}\n'


@pytest.fixture
def wrapper(test_dir):
    os.symlink('../bin/python-exec2', test_dir / 'test')
    yield test_dir / 'test'


@pytest.fixture
def subset_wrapped(test_dir, every_python):
    for python in PYTHON_IMPLS:
        os.mkdir(test_dir / python)
        with open(test_dir / python / 'test', 'w') as f:
            os.chmod(f.fileno(), 0o755)
            f.write(PROGRAM.format(python=python))
        if python == every_python:
            break
    yield every_python


@pytest.fixture
def all_wrapped(test_dir):
    for python in PYTHON_IMPLS:
        os.mkdir(test_dir / python)
        with open(test_dir / python / 'test', 'w') as f:
            os.chmod(f.fileno(), 0o755)
            f.write(PROGRAM.format(python=python))


class PyExecConf:
    def __init__(self, confdir):
        self.confdir = confdir

    def open(self, filename='python-exec.conf'):
        return open(self.confdir / filename, 'w')


@pytest.fixture
def pyexec_conf(test_dir):
    os.makedirs(test_dir / 'etc/python-exec')
    yield PyExecConf(test_dir / 'etc/python-exec')


def test_default_order(wrapper, subset_wrapped):
    """Test that with no overrides, default order is respected."""
    env = dict(os.environ)
    env.pop('EPYTHON', None)
    assert (subprocess.check_output([wrapper], env=env) ==
            f'{subset_wrapped}\n'.encode('ASCII'))


@pytest.mark.parametrize('config', ['', 'python-exec.conf', 'test.conf'])
def test_epython(nonbest_python, wrapper, all_wrapped, config, pyexec_conf):
    """Test that EPYTHON overrides both the default order and config."""
    env = dict(os.environ)
    env['EPYTHON'] = nonbest_python
    if config:
        with pyexec_conf.open(config) as f:
            f.write(f'{PYTHON_IMPLS[-1]}\n')
    assert (subprocess.check_output([wrapper], env=env) ==
            f'{nonbest_python}\n'.encode('ASCII'))


@pytest.mark.parametrize(
    'config,ignored_config',
    [('python-exec.conf', ''),
     ('test.conf', ''),
     ('test.conf', 'python-exec.conf'),
     ])
def test_conf(nonbest_python, wrapper, all_wrapped, config, ignored_config,
              pyexec_conf):
    """Test that python-exec.conf overrides the default order."""
    env = dict(os.environ)
    env.pop('EPYTHON', None)
    with pyexec_conf.open(config) as f:
        f.write(f'{nonbest_python}\n')
    if ignored_config:
        with pyexec_conf.open(ignored_config) as f:
            f.write(f'{PYTHON_IMPLS[-1]}\n')
    assert (subprocess.check_output([wrapper], env=env) ==
            f'{nonbest_python}\n'.encode('ASCII'))


@pytest.mark.parametrize(
    'config,ignored_config',
    [('python-exec.conf', ''),
     ('test.conf', ''),
     ('test.conf', 'python-exec.conf'),
     ])
@pytest.mark.parametrize('epython_set', ['', 'epython'])
def test_conf_disable(nonbest_python, wrapper, all_wrapped, config,
                      ignored_config, pyexec_conf, epython_set):
    """Test that disabling impls overrides everything."""
    env = dict(os.environ)
    with pyexec_conf.open(config) as f:
        for python in reversed(PYTHON_IMPLS):
            env['EPYTHON'] = python
            if python == nonbest_python:
                break
            f.write(f'-{python}\n')
    if ignored_config:
        with pyexec_conf.open(ignored_config) as f:
            f.write(f'{PYTHON_IMPLS[-1]}\n')
    if not epython_set:
        del env['EPYTHON']
    assert (subprocess.check_output([wrapper], env=env) ==
            f'{nonbest_python}\n'.encode('ASCII'))
