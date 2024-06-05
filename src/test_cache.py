# (c) 2021 Michał Górny
# 2-clause BSD license

"""Tests for caching fetcher"""

import os.path
import time

import pytest
import requests
import responses

from kuroneko.cache import cached_get


TEST_URL = 'https://example.com/test.txt'


@responses.activate
def test_cache_new(tmp_path):
    responses.add(responses.GET, TEST_URL, b'foobar')

    now = int(time.time())
    with cached_get(TEST_URL, tmp_path / 'test.txt') as f:
        assert f.read() == b'foobar'
    assert os.path.exists(tmp_path / 'test.txt')
    assert int(os.stat(tmp_path / 'test.txt').st_mtime) >= now


@responses.activate
def test_404(tmp_path):
    responses.add(responses.GET, TEST_URL, status=404)
    with pytest.raises(requests.HTTPError):
        cached_get(TEST_URL, tmp_path / 'test.txt')


@responses.activate
def test_cache_no_update(tmp_path):
    with open(tmp_path / 'test.txt', 'wb') as f:
        f.write(b'bar')
    with cached_get(TEST_URL, tmp_path / 'test.txt') as f2:
        assert f2.read() == b'bar'


@responses.activate
def test_cache_update_no_change(tmp_path):
    responses.add(responses.GET, TEST_URL, status=304)
    with open(tmp_path / 'test.txt', 'wb') as f:
        f.write(b'bar')
        f.flush()
        os.utime(f.fileno(), (1623002816, 1623002816))

    now = int(time.time())
    with cached_get(TEST_URL, tmp_path / 'test.txt') as f2:
        assert f2.read() == b'bar'
    assert os.path.exists(tmp_path / 'test.txt')
    assert int(os.stat(tmp_path / 'test.txt').st_mtime) >= now


@responses.activate
def test_cache_update_change(tmp_path):
    responses.add(responses.GET, TEST_URL, b'foobar')
    with open(tmp_path / 'test.txt', 'wb') as f:
        f.write(b'bar')
        f.flush()
        os.utime(f.fileno(), (1623002816, 1623002816))

    now = int(time.time())
    with cached_get(TEST_URL, tmp_path / 'test.txt') as f2:
        assert f2.read() == b'foobar'
    assert os.path.exists(tmp_path / 'test.txt')
    assert int(os.stat(tmp_path / 'test.txt').st_mtime) >= now
