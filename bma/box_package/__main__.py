""" Main file for the app."""

import network_as_code as nac
import pytest
from app import App
from helpers import Database
from network_as_code.models.device import DeviceIpv4Addr
from report import Report

# We begin by creating a Network-as-Code client
client = nac.NetworkAsCodeClient(token="d0c3366c43msh32fdce6d032215ep15d5ddjsnc2f2f9591360")

# Then, create a device object
# The "device@testcsp.net" should be replaced with a test device copied from your Developer Sandbox
# Or identify a device with its ID, IP address(es) and optionally, a phone number
device = client.devices.get(
    ipv4_address=DeviceIpv4Addr(public_address="233.252.0.2", private_address="192.0.2.25", public_port=80),
    # The phone number accepts the "+" sign, but not spaces or "()" marks
    phone_number="21431000060",
)

# ...and create a QoD session for the device
session = device.create_qod_session(
    service_ipv4="233.252.0.2", service_ipv6="2001:db8:1234:5678:9abc:def0:fedc:ba98", profile="DOWNLINK_L_UPLINK_L"
)


### MAIN LOOP APP:

if __name__ == "__main__":
    # Instantiate the database and the app
    db = Database()
    app = App(db, device)
    # app.run() # This would be the main loop of the app, when connected with the front_end

    ##############
    ### TEST 0 ###
    ##############
    # User tries to create a report far from the device location and then with bounty without points:
    with pytest.raises(ValueError, match="Report location is far from current location."):
        report0 = app.add_report(
            user=app.user,
            location=(0, 0),
            category="",
            title="Issue 0",
            description="This is the zeroth issue",
            image=None,
            status="pending",
            bounty=0,
        )
    with pytest.raises(ValueError, match="Not enough points to set this bounty"):
        report0 = app.add_report(
            user=app.user,
            location=(device.location().longitude, device.location().latitude),
            category="",
            title="Issue 0",
            description="This is the zeroth issue",
            image=None,
            status="pending",
            bounty=10,
        )

    ##############
    ### TEST 1 ###
    ##############
    # Original user closes an issue, trying upvotes before and after + getting the user and the report by name:

    # Opening report, upvote and downvote, change status, and give points to user:
    report1 = app.add_report(
        user=app.user,
        location=(device.location().longitude, device.location().latitude),
        category="test",
        title="Issue 1",
        description="This is the first issue",
        image=None,
        bounty=0,
    )
    assert report1.status == "pending"
    app.upvote(app.user, report1)
    assert report1.status == "active"
    app.downvote(app.user, report1)
    assert app.user.points == 3
    assert report1.upvotes == report1.downvotes == 1

    # User resolves the report, and then invalidates upvote and downvote:
    app.resolve_report(app.user, report1)
    assert report1.status == "resolved"
    with pytest.raises(ValueError, match="You can't upvote a resolved report"):
        # User upvotes a already closed report
        app.upvote(app.user, report1)
    with pytest.raises(ValueError, match="You can't downvote a resolved report"):
        # User downvotes an already closed report
        app.downvote(app.user, report1)

    # Get user and report by name:
    user = app.get_user("default")
    report = app.get_report("Issue 1")
    assert report == report1
    assert user.name == "default"

    ##############
    ### TEST 2 ###
    ##############
    # Another user (from the one that created it) tries to close an issue, then it gets closed by downvotes + bounty try

    # Create a report with a bounty of 10 points:
    app.user.points = 100  # Manual set for testing purposes
    report2 = app.add_report(
        user=app.user,
        location=(device.location().longitude, device.location().latitude),
        category="test",
        title="Issue 2",
        description="This is the second issue",
        image=None,
        bounty=10,
    )
    assert user.points == 91

    # User2 tries to resolve a report, that is not his:
    user2 = app.add_user(
        name="default2", device=device, location=(device.location().latitude, device.location().longitude)
    )
    with pytest.raises(ValueError, match="Only the user who created the report or admin users can resolve the report"):
        # User2 tries to resolve a report, that is not his
        app.resolve_report(app.get_user("default2"), report2)

    # With 5 downvotes the report gets closed:
    assert report2.status == "pending"
    for i in range(5):
        app.downvote(app.user, report2)
    assert user.points == 101
    assert report2.status == "resolved"
    with pytest.raises(ValueError, match="You can't downvote a resolved report"):
        app.downvote(app.user, report2)

    ##############
    ### TEST 3 ###
    ##############
    # Another user can see the previous near created reports.

    # Adding a far report into the DB:
    far_report = Report(
        id=1000000,
        title="title",
        user_id=1111111,
        location=(0, 0),
        category="test",
        description="test",
        image=None,
        status="pending",
        bounty=0,
    )
    db.insert_report(far_report)
    assert db.get_report("title") == far_report
    assert db.reports["title"] == far_report

    # The far report, doesnt get shown to the user, since its far:
    close_reports = app.get_close_reports(user, db)
    assert far_report not in close_reports
    assert [report1, report2] == close_reports

device.clear_sessions()
