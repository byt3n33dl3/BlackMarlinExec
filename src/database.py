# (c) 2021 Michał Górny
# 2-clause BSD license

"""Bug database abstraction."""

import json
import typing

from kuroneko import __version__


class Bug(typing.NamedTuple):
    """Tuple representing bug in the database."""

    bug: int
    packages: typing.List[typing.List[str]]
    summary: str
    severity: str
    created: str
    resolved: bool


class DatabaseError(RuntimeError):
    """Error loading the database."""


class Database:
    """Bug database."""

    bugs: typing.Dict[int, Bug]

    SCHEMA_VERSION = [int(x) for x in __version__.split('.', 2)[:2]]

    def __init__(self) -> None:
        """Init an empty database."""
        self.bugs = {}

    def load(self, fileobj: typing.IO) -> None:
        """Load database from open JSON file."""
        data = json.load(fileobj)
        try:
            kv = data['kuroneko-version']
            if not isinstance(kv, str):
                raise ValueError()
            major, minor = (int(x) for x in kv.split('.', 1))
        except KeyError:
            raise DatabaseError('No kuroneko-version in database file')
        except ValueError:
            raise DatabaseError('Incorrect kuroneko-version value')
        if major != self.SCHEMA_VERSION[0]:
            raise DatabaseError(f'Incompatible database schema {major}.'
                                f'{minor} ({self.SCHEMA_VERSION} is '
                                f'the current version')

        self.bugs = {}
        for bug in data['bugs']:
            self.bugs[bug['bug']] = Bug(**bug)

    def save(self, fileobj: typing.IO) -> None:
        """Save database into open JSON file."""
        json.dump({
            'kuroneko-version': '.'.join(str(x)
                                         for x in self.SCHEMA_VERSION),
            'bugs': list(x._asdict() for x in self.bugs.values()),
            }, fileobj)

    def add_bug(self,
                bug: int,
                packages: typing.List[typing.List[str]],
                summary: str,
                severity: str,
                created: str,
                resolved: bool,
                ) -> None:
        """Add a new bug to the database."""
        self.bugs[bug] = Bug(
            bug=bug,
            packages=packages,
            summary=summary,
            severity=severity,
            created=created,
            resolved=resolved,
            )
