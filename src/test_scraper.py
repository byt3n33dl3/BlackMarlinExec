# (c) 2021 Michał Górny
# 2-clause BSD license

"""Tests for scraping support"""

import pytest
import responses

from pkgcore.ebuild.atom import atom

from kuroneko.scraper import (
    BugInfo, find_security_bugs, find_package_specs, get_severity,
    split_version_ranges,
    )


@responses.activate
def test_bugzilla_scraping():
    expected = [
        BugInfo(
            alias=['CVE-2014-3800'],
            id=536366,
            summary='media-tv/kodi: Password disclosure vulnerability '
                    '(CVE-2014-3800)',
            whiteboard='B3 [upstream cve]',
            creation_time='2016-03-01T17:31:35Z',
            resolution='---',
            ),
        BugInfo(
            alias=[],
            id=576134,
            summary='app-emulation/wine: Insecure use of temp files '
                    'with predictable names',
            whiteboard='B4 [upstream]',
            creation_time='2016-03-01T17:31:35Z',
            resolution='---',
            ),
        BugInfo(
            alias=['CVE-2013-4392'],
            id=600624,
            summary='sys-apps/systemd: TOCTOU race condition when '
                    'updating file permissions and SELinux security '
                    'contexts',
            whiteboard='~3 [upstream cve]',
            creation_time='2016-11-23T20:58:05Z',
            resolution='---',
            ),
        BugInfo(
            alias=[],
            id=602594,
            summary='app-accessibility/eflite: root privilege '
                    'escalation',
            whiteboard='B1 [ebuild]',
            creation_time='2016-12-14T02:41:52Z',
            resolution='---',
            ),
    ]
    bugs_json = [x._asdict() for x in expected]

    responses.add(responses.GET,
                  'https://bugs.gentoo.org/rest/bug?product=Gentoo+Security&'
                  'component=Vulnerabilities&include_fields=id&'
                  'include_fields=summary&include_fields=alias&'
                  'include_fields=whiteboard&'
                  'include_fields=creation_time&include_fields=resolution&'
                  'limit=10000&offset=0',
                  json={'bugs': bugs_json})
    responses.add(responses.GET,
                  'https://bugs.gentoo.org/rest/bug?product=Gentoo+Security&'
                  'component=Vulnerabilities&include_fields=id&'
                  'include_fields=summary&include_fields=alias&'
                  'include_fields=whiteboard&'
                  'include_fields=creation_time&include_fields=resolution&'
                  'limit=10000&offset=4',
                  json={'bugs': []})

    assert list(find_security_bugs()) == expected


@pytest.mark.parametrize(
    'spec,expected',
    [('dev-foo/bar: funny vuln', ['dev-foo/bar']),
     ('<dev-foo/bar-12: funny', ['<dev-foo/bar-12']),
     ('<dev-foo/bar-{12.2,14}: funny', ['<dev-foo/bar-12.2',
                                        '<dev-foo/bar-14']),
     ('dev-foo/{bar,baz} lalala', ['dev-foo/bar', 'dev-foo/baz']),
     ('~dev-foo/bar-14[sqlite]', ['~dev-foo/bar-14']),
     ('dev-foo/bar, dev-foo/baz, CVE-12345', ['dev-foo/bar',
                                              'dev-foo/baz']),
     ('<>dev-foo/baz: imma big junk', []),
     ('dev-foo/bar:{1.3,1.4}', ['dev-foo/bar:1.3', 'dev-foo/bar:1.4']),
     ('<dev-foo/bar-{1.3.2:1.3,1.4.7:1.4}', ['<dev-foo/bar-1.3.2:1.3',
                                             '<dev-foo/bar-1.4.7:1.4']),
     ('<dev-foo/bar-1.2.3 with dev-bar/frobnicate-13: something',
      ['<dev-foo/bar-1.2.3']),
     ])
def test_find_package_specs(spec, expected):
    assert sorted(str(x) for x in find_package_specs(spec)) == expected


@pytest.mark.parametrize(
    'wb,expected',
    [('B3 [upstream cve]', 'B3'),
     ('B4 [upstream]', 'B4'),
     ('~3 [upstream cve]', '~3'),
     ('B3 [ebuild]', 'B3'),
     ('A4 [upstream/ebuild cve]', 'A4'),
     ('A2 [stable blocked]', 'A2'),
     ('B1 [glsa masked cve]', 'B1'),
     ('~4 [cleanup]', '~4'),
     ('A2 [glsa? cve]', 'A2'),
     ('C1 [glsa? cleanup]', 'C1'),
     ('?? [glsa?]', '??'),
     ('', '??'),
     ('random stuff', '??'),
     ])
def test_get_severity(wb, expected):
    assert get_severity(wb) == expected


@pytest.mark.parametrize(
    'pkgs,expected',
    [(['<dev-foo/bar-7'], [['<dev-foo/bar-7']]),
     (['<dev-foo/bar-3.4', '<dev-foo/bar-7.2'],
      [['<dev-foo/bar-3.4'], ['>=dev-foo/bar-4', '<dev-foo/bar-7.2']]),
     (['<dev-foo/bar-3.6.11_p2',
       '<dev-foo/bar-3.7.7_p1',
       '<dev-foo/bar-3.8.4',
       '<dev-foo/bar-3.9.1'],
      [['<dev-foo/bar-3.6.11_p2'],
       ['>=dev-foo/bar-3.7', '<dev-foo/bar-3.7.7_p1'],
       ['>=dev-foo/bar-3.8', '<dev-foo/bar-3.8.4'],
       ['>=dev-foo/bar-3.9', '<dev-foo/bar-3.9.1'],
       ]),
     (['dev-foo/bar', 'dev-foo/baz'], [['dev-foo/bar'], ['dev-foo/baz']]),
     (['<dev-foo/bar-1.2', '<dev-foo/bar-1.2-r100'],
      [['<dev-foo/bar-1.2'], ['<dev-foo/bar-1.2-r100']]),
     (["<net-libs/webkit-gtk-2.42.2:4",
       "<net-libs/webkit-gtk-2.42.2:4.1",
       "<net-libs/webkit-gtk-2.42.2:6"],
      [["<net-libs/webkit-gtk-2.42.2:4"],
       ["<net-libs/webkit-gtk-2.42.2:4.1"],
       ["<net-libs/webkit-gtk-2.42.2:6"],
       ]),
     ])
def test_split_version_ranges(pkgs, expected):
    assert list(split_version_ranges(atom(x) for x in pkgs)) == expected
