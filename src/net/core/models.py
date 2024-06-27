# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from neomodel import (config, StructuredNode, StringProperty, IntegerProperty,
    UniqueIdProperty, RelationshipTo, RelationshipFrom, Relationship)

config.DATABASE_URL = 'bolt://neo4j:Neo4j@localhost:4444'

class Machine(StructuredNode):
    uid = UniqueIdProperty()
    ip = StringProperty(unique_index=True)
    subnet = StringProperty(unique_index=True)
    hostname = StringProperty(unique_index=True)
    tag = StringProperty(unique_index=True)
    distance = IntegerProperty()
    queue = IntegerProperty()
    action = StringProperty()
    enum = StringProperty()
    cloud = StringProperty()
    connected = Relationship('Machine','IS_CONNECTED')
    def __str__(self):
        return self.hostname
        
    def makeanode(ip,subnet,project,distance,origin,enum,doenum):
    try:
        checknode = Machine.nodes.get(ip=ip,tag__startswith=project)
        print "Node exist: " + checknode.ip
        if doenum:
            nmapenumeration(checknode)
        else:
            checknode.enum = enum
            checknode.save()
    except Machine.DoesNotExist as ex:
        print "Exception: " + str(ex)
        try:
            hostname = socket.gethostbyaddr(ip.split("#")[0])[0]
        except Exception as ex:
            print "Exception: " + str(ex)
            hostname = ip
        print "Hostname: " + hostname

        count = len(Machine.nodes.filter(distance=distance).filter(tag__startswith=project))
        if ipaddress.ip_address(unicode(ip.split("#")[0])).is_private:
            tag = project + "#" + origin + "exist"
        else:
            tag = project + "#" + origin + "not_hosted"
