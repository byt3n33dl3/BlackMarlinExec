"""Report module for the app."""

import json


class Report:
    """Report class for the app."""

    def __init__(
        self,
        id: int,
        title: str,
        user_id: int,
        location: tuple[float],
        category: str,
        description: str = "",
        image=None,
        status: str = "pending",
        bounty: int = 0,
    ):
        self.id: int = id
        self.title: str = title
        self.user_id: int = user_id
        self.location: tuple[float] = location  # bus, metro, bicycles, rentHousing, pets, parking, garbage, trees...
        self.category: str = category
        self.status: str = status  # pending, active and resolved
        self.bounty: int = bounty
        self.description: str = description
        self.image = image
        self.upvotes: int = 0
        self.downvotes: int = 0

    def close(self) -> None:
        """Close the report."""
        self.status = "resolved"

    def upvote(self) -> None | str:
        """Upvote the report."""
        if self.status == "pending":
            self.status = "active"
        if self.status == "resolved":
            raise ValueError("You can't upvote a resolved report")
        self.upvotes += 1

    def downvote(self) -> None | str:
        """Downvote the report."""
        if self.status == "resolved":
            raise ValueError("You can't downvote a resolved report")
        self.downvotes += 1
        if self.downvotes - self.upvotes >= 5:
            self.close()

    def to_dict(self) -> dict:
        """Convert the report to a dictionary."""
        return {
            "id": self.id,
            "title": self.title,
            "user_id": self.user_id,
            "location": self.location,
            "category": self.category,
            "description": self.description,
            "image": self.image,
            "status": self.status,
            "bounty": self.bounty,
            "upvotes": self.upvotes,
            "downvotes": self.downvotes,
        }

    def to_json(self) -> str:
        """Convert the report to a json string."""
        return json.dumps(self.to_dict())

    @classmethod
    def from_dict(cls, report_dict: dict) -> "Report":
        """Load the user from a dictionary."""
        cls(**report_dict)

    @classmethod
    def from_json(cls, report_json: str) -> "Report":
        """Load the user from a JSON string."""
        cls(**json.loads(report_json))

    def __str__(self) -> str:
        return f"Report: {self.title}, Bounty: {self.bounty}, Upvotes: {self.upvotes}, Downvotes: {self.downvotes}, Resolutions: {len(self.resolutions)}, Closed: {self.closed}"
