"""Helper module for the app with database and APIs mocks."""

from report import Report
from user import User


class NokiaLocationRetrieval:
    """Class for the Nokia Location Retrieval API."""

    def __init__(self, device):
        self.device = device

    def get(self):
        return self.device.location()


class NokiaLocationVerification:
    """Class for the Nokia Location Verification API."""

    def __init__(self, device, location, radius=1000):
        self.device = device
        self.longitude = location[0]
        self.latitude = location[1]
        self.radius = radius

    def get(self):
        return self.device.verify_location(self.longitude, self.latitude, self.radius)


class Database:
    """Database class for the app."""

    def __init__(self):
        self.users: dict[str, User] = {}
        self.reports: dict[str, Report] = {}

    def insert_user(self, user: User):
        """Insert a user to the database."""
        self.users[user.name] = user

    def insert_report(self, report: Report):
        """Insert a report to the database."""
        self.reports[report.title] = report

    def update_report(self, report: Report):
        """Update a report to the database."""
        if report.title in self.reports:
            self.reports[report.title] = report

    def update_user(self, user: User):
        """Update a user to the database."""
        if user.name in self.users:
            self.users[user.name] = user

    def get_user(self, name: str):
        """Get a user from the database."""
        return self.users.get(name)

    def get_report(self, title: str):
        """Get a report from the database."""
        return self.reports.get(title)
