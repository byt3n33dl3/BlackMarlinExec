import network_as_code as nac
 
from network_as_code.models.device import DeviceIpv4Addr
 
# We begin by creating a Network-as-Code client
client = nac.NetworkAsCodeClient(
    token="0b7b898687msh7007d40f6f284c6p1bb43ejsn77e888578525"
)
 
# Then, create a device object
# The "device@testcsp.net" should be replaced with a test device copied from your Developer Sandbox
# Or identify a device with its ID, IP address(es) and optionally, a phone number
device = client.devices.get(phone_number = "2143100001", ipv4_address="233.252.0.2")
 
# ...and create a QoD session for the device
session = device.create_qod_session(
	service_ipv4="233.252.0.2",
	# service_ipv6="2001:db8:1234:5678:9abc:def0:fedc:ba98",
	profile="DOWNLINK_L_UPLINK_L"
)

# Let's confirm that the device has the newly created session
print(device.sessions())

print(client.sessions)

# Finally, remember to clear out the sessions for the device
device.clear_sessions()

print(client.sessions)

loc = device.location(60)

print(f"STATUS - {device.json()}")

print(f"LOC - {loc}")