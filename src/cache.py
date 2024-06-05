# (c) 2021 Michał Górny
# 2-clause BSD license

"""Caching URL getter."""

import datetime
import email.utils
import errno
import io
import os
import time
import typing

import requests


CACHE_EXPIRE = 600


def cached_get(url: str,
               cache_path: str,
               ) -> typing.IO:
    """Fetch specified url, using cache_path file as local cache."""
    resp = None

    try:
        f = open(cache_path, 'rb')
    except OSError as e:
        if e.errno != errno.ENOENT:
            raise
    else:
        try:
            st = os.stat(f.fileno())
            # do not issue a request if we fetched it recently
            if time.time() - st.st_mtime < CACHE_EXPIRE:
                return f

            # issue a request with Last-Modified
            last_modified = email.utils.format_datetime(
                datetime.datetime.utcfromtimestamp(st.st_mtime))
            resp = requests.get(url, headers={'Last-Modified': last_modified})
            resp.raise_for_status()
            if resp.status_code == 304:
                # update the timestamp to avoid repeating the request
                # for the next CACHE_EXPIRE period
                os.utime(f.fileno())
                return f
        except Exception as e:
            f.close()
            raise e
        f.close()

    if resp is None:
        resp = requests.get(url)
        resp.raise_for_status()

    with open(cache_path, 'wb') as f2:
        f2.write(resp.content)

    return io.BytesIO(resp.content)
