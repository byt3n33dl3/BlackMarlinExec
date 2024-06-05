"""User module for the app."""

import json

import numpy as np
from report import Report


class User:
    """User class for the app."""

    def __init__(self, name: str, device: int, location: tuple[float], is_admin: bool = False):
        self.id = np.random.randint(0, 999999999)
        self.name: str = name
        self.is_admin: bool = is_admin
        self.points: int = 0
        self.device = device
        self.location: tuple[float] = location

    def report_issue(self, title, location, category, description, image, status="pending", bounty=0) -> Report | str:
        """Report an issue."""
        if self.points < bounty:
            raise ValueError("Not enough points to set this bounty")

        self.points -= bounty
        self.points += 1
        return Report(
            id=np.random.randint(0, 999999999),
            title=title,
            user_id=self.id,
            location=location,
            category=category,
            description=description,
            image=image,
            status=status,
            bounty=bounty,
        )

    def resolve_report(self, report: Report) -> str | None:
        if not report.user_id == self.id and not self.is_admin:
            raise ValueError("Only the user who created the report or admin users can resolve the report")

        report.status = "resolved"

    def contribution_award(self, report: Report) -> None:
        """Upvote/downvote report award."""
        self.points += 1
        self.points += report.bounty // 10

    def to_dict(self) -> dict:
        """Return the user as a dictionary."""
        return {
            "id": self.id,
            "name": self.name,
            "is_admin": self.is_admin,
            "points": self.points,
            "device": self.device,
            "location": self.location,
        }

    def to_json(self) -> str:
        """Return the user as a JSON string."""
        return json.dumps(self.to_dict())

    @classmethod
    def from_dict(cls, user_dict: dict) -> "User":
        """Load the user from a dictionary."""
        cls(**user_dict)

    @classmethod
    def from_json(cls, user_json: str) -> "User":
        """Load the user from a JSON string."""
        return cls.from_dict(json.loads(user_json))

    def __str__(self) -> str:
        return f"User: {self.name}, Points: {self.points}"
