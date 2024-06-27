# python-exec -- core tests
# (c) 2021 Michał Górny
# Licensed under the terms of the 2-clause BSD license.

import errno
import os
import pathlib
import shutil
import subprocess
import typing

import pytest


PROGRAMS = {
    'shell': '#!/bin/sh\necho {python}\n',
    'python': '#!/usr/bin/env python\nprint("{python}")\n',
}

BUFSIZE = int(subprocess.check_output(['test/bin/print-bufsiz']))


class WrapperRunnerProgramTuple(typing.NamedTuple):
    test_dir: pathlib.Path
    wrapper: str
    args: typing.List[str]
    program: str
    python: str
    transform: typing.Optional[typing.Callable[[str], str]]
    env: typing.Dict[str, str]


def wrapper_runner_program_id(param):
    wrapper, runner, program, transform, suffix_len = param
    return (f'{wrapper}-{runner}-{program}-'
            f'{transform.__name__ if transform is not None else None}-'
            f'{suffix_len}')


@pytest.fixture(
    params=[('python-exec2', '', 'shell', None, 0),
            ('python-exec2', '', 'python', None, 0),
            ('python-exec2', '', 'shell', os.path.basename, 0),
            ('python-exec2', '', 'python', os.path.basename, 0),
            ('python-exec2', '{python}', 'python', None, 0),
            ('python-exec2c', '', 'shell', None, 0),
            ('python-exec2c', '', 'python', None, 0),
            ('python-exec2c', '', 'shell', os.path.basename, 0),
            ('python-exec2c', '', 'python', os.path.basename, 0),
            pytest.param(('python-exec2c', '', 'shell', None, BUFSIZE),
                         marks=pytest.mark.xfail),
            pytest.param(('python-exec2c', '', 'shell', os.path.basename,
                          BUFSIZE),
                         marks=pytest.mark.xfail),
            ],
    ids=wrapper_runner_program_id)
def wrapper_runner_program(request, test_dir, every_python, copy_method):
    """Create a wrapper and a wrapped program for testing."""
    wrapper, runner, program, transform, suffix_len = request.param
    test_name = 'test' + suffix_len * 'x'
    test_arg = str(test_dir / test_name)
    if transform is not None:
        test_arg = transform(test_arg)
    args = runner.format(python=every_python).split() + [test_arg]
    program = PROGRAMS[program].format(python=every_python)
    env = dict(os.environ)
    env['PATH'] = f'{test_dir}:{env["PATH"]}'

    os.mkdir(test_dir / every_python)
    try:
        with open(test_dir / every_python / test_name, 'w') as f:
            os.chmod(f.fileno(), 0o755)
            f.write(program)
        copy_method((test_dir / '../bin' / wrapper).absolute(),
                    test_dir / test_name)
    except OSError as e:
        if e.errno == errno.ENAMETOOLONG:
            pytest.skip('Buffer larger than max name length')
        raise
    yield WrapperRunnerProgramTuple(test_dir,
                                    wrapper,
                                    args,
                                    program,
                                    every_python,
                                    transform,
                                    env)


def test_single(wrapper_runner_program):
    """Test running the wrapper with a single impl directory available."""
    t = wrapper_runner_program
    assert (subprocess.check_output(t.args, env=t.env) ==
            f'{t.python}\n'.encode('ASCII'))


def test___file__(test_dir, every_python, copy_method):
    """Test for correct __file__ when spawning via Python wrapper."""
    os.mkdir(test_dir / every_python)
    with open(test_dir / every_python / 'test', 'w') as f:
        os.chmod(f.fileno(), 0o755)
        f.write('#!/usr/bin/env python\nprint(__file__)\n')
    copy_method((test_dir / '../bin/python-exec2').absolute(),
                test_dir / 'test')
    assert (subprocess.check_output([every_python, str(test_dir / 'test')]) ==
            subprocess.check_output([every_python, str(test_dir / every_python /
                                                       'test')]))


@pytest.mark.symlink
@pytest.mark.parametrize('transform', [None, os.path.abspath])
@pytest.mark.parametrize('depth', [1, 3])
def test_symlink(wrapper_runner_program, transform, depth):
    """Test that symlinks to the wrapped executable work."""
    t = wrapper_runner_program
    target = 'test'
    while depth > 0:
        sym = t.test_dir / f'symlink.{depth}'
        if transform is not None:
            target = transform(t.test_dir / target)
        os.symlink(target, sym)
        target = sym.name
        depth -= 1
    t.args[-1] = str(sym)
    if t.transform is not None:
        t.args[-1] = t.transform(t.args[-1])
    assert (subprocess.check_output(t.args, env=t.env) ==
            f'{t.python}\n'.encode('ASCII'))


@pytest.mark.parametrize('wrapper', ['python-exec2', 'python-exec2c'])
def test_python_argv0(test_dir, every_python, copy_method, wrapper):
    """Test that sys.executable is correct inside wrapped Python."""
    os.mkdir(test_dir / every_python)
    os.symlink(shutil.which(every_python),
               test_dir / every_python / 'python')
    copy_method((test_dir / '../bin' / wrapper).absolute(),
                test_dir / 'python')
    code = 'import os.path, sys; print(os.path.realpath(sys.executable))'
    assert (
        subprocess.check_output([every_python, '-c', code]) ==
        subprocess.check_output([test_dir / 'python', '-c', code]))
