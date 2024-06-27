import os
import sys

# Checks for available python version (ipaddress module included in 3.3 and after)
version = sys.version_info
if version[0] < 3 or (version[0] == 3 and version[1] < 3):
    raise OSError("You are not using the correct version of Python. Python 3.3 or higher is required for this program to execute.")

import ipaddress as ipaddr
import argparse
import graphviz


# Function to convert an IP address and a mask into CIDR notation
def ipNetworkFromMask(addressString,subnetMaskString):
    '''
       Converts a given address (in the form of a string)
       and a subnet mask (as a string) to an IPv4Network object,
       which allows manipulation and displays as a CIDR notated network.
    '''
    return ipaddr.ip_network("{0}/{1}".format(addressString,subnetMaskString),strict=False)

# Function to make sure the user has passed in a valid file
def validateFile(fileName):
    try:
        f = open(fileName)
        f.close()
    except OSError:
        print("The file could not be opened. Use the '-h' argument for help.")
        sys.exit(1)
        
    return(fileName)

# Function for debugging that prints out the all data structures and their data
def printDataTree(vlansDict,contextsDict):
    print("\n---VLANS---\n")
    for i in vlansDict:
        print("{0} : {1}".format(i,vlansDict[i]))
    print("\n---CONTEXTS---\n")
    for i in contextsDict:
        print("{0} : {1}".format(i,contextsDict[i]))

#------------------------------------------------------------------------------------------------------#

# Process arguments from the user
parser = argparse.ArgumentParser(
    description = 'A python script that visually maps network configurations automatically.',
    epilog = 'example: python NetworkMap.py -c fwsm_contexts.txt -s fwsm_contexts.txt  -f switch_config.txt -v switch_vlans.txt')
requiredNamed = parser.add_argument_group('required arguments')
requiredNamed.add_argument("-c", "--contexts", nargs="+", help="Name of the FWSM contexts file", required=True)
requiredNamed.add_argument("-f", "--config", nargs="+", help="Name of the distribution switch config file", required=True)
requiredNamed.add_argument("-s", "--system", nargs="+", help="Name of the FWSM system level file", required=True)
requiredNamed.add_argument("-v", "--vlans", nargs="+", help="Name of the distribution switch vlans file", required=True)

# Parse the arguments passed in and validate them
args = parser.parse_args()
# Firewall files
if args.contexts:
    for c in args.contexts:
        contextsFileName = validateFile(c)
if args.system:
    for s in args.system:
        sysLevelFileName = validateFile(s)
# Switch files
if args.vlans:
    for v in args.vlans:
        vlansFileName = validateFile(v)
if args.config:
    for f in args.config:
        switchConfigFileName = validateFile(f)

#------------------------------------------------------------------------------------------------------#

vlansDict = {}  # {"Vlan0":{"interface":None,"description":"abc\n123","ip":"192.168.0.0/24"},"Vlan1":{...},...}
contextsDict = {}  # {"contextA1":{"description":"","outside":["vlan0"],"inside":["vlan1","vlan2",...]},"contextB2":{...},...}
nameOfSwitch = "Distribution Switch"  # holds the name of the distribution switch


# STEP 1: read all vlans into the Vlan dict
with open(vlansFileName,"r") as vlansFile:
    for line in vlansFile:
        lineList = line.split()
        if len(lineList) > 1:  # make sure we don't go out of bounds on an empty line
            if lineList[0] == "VLAN" and lineList[1] == "Type":
                # Reached end of Vlan list, so break
                break
        
        # make sure the string starts with an integer
        startsWithVlanNum = True
        try:
            int(lineList[0])  # fails if the string is not an integer (i.e. the line didn't start with an integer of a Vlan, or it's an empty line)
        except:
            startsWithVlanNum = False
        
        if(startsWithVlanNum):
            vlansDict["Vlan{0}".format(lineList[0])] = {"interface":None,"description":"","ip":""}


# STEP 2: Read contexts into the context dict & write down inside and outside vlans. Also put "name" as descriptor for vlans
with open(sysLevelFileName,"r") as sysLvlFile:
    contextIndex = ""  # used to keep track of the current context being worked on
    for line in sysLvlFile:  # loop through the file
        lineList = line.split()
        if(len(lineList) > 0):  # avoid errors with empty lines
            if(lineList[0] == "context"):  # found a relevant section header
                contextIndex = lineList[1]
                contextsDict[contextIndex] = {"description":"","outside":[],"inside":[]}  # build the data structure for that section
                
                while(lineList[0] != "!"):  # parse the section until we reach an "end of secion" marker (denoted by a single "!")
                    line = next(sysLvlFile)
                    lineList = line.split()
                    
                    if lineList[0] == "description":
                        contextsDict[contextIndex]["description"] = " ".join(lineList[1:])  # concatenate the description and add it to the data structure
                    elif lineList[0] == "allocate-interface":
                        vlanName = lineList[1]
                        interfaceName = lineList[2]
                        try:
                            vlansDict[vlanName]["interface"] = interfaceName  # assign a Vlan to an interface, create the vlan entry if it didnt exist
                        except KeyError:
                            vlansDict[vlanName] = {"interface":interfaceName,"description":"","ip":""}
                            
                        # log how the Vlan is related to the context
                        if interfaceName == "outside":
                            contextsDict[contextIndex]["outside"].append(vlanName)
                        else:
                            contextsDict[contextIndex]["inside"].append(vlanName)


# STEP 3: Copy ips and descriptions for vlans
with open(switchConfigFileName,"r") as switchConfigFile:
    vlanIndex = ""
    # Get the name of the switch
    for line in switchConfigFile:
        lineList = line.split()
        if len(lineList) > 0:  # skip empty lines
            if lineList[0] == "hostname":
                nameOfSwitch = lineList[1]
                break
    # Get the Vlan data
    for line in switchConfigFile:
        lineList = line.split()
        if len(lineList) > 0:  # skip empty lines
            if lineList[0] == "interface" and lineList[1][0:4] == "Vlan":
                vlanIndex = lineList[1]  # copy the index of the Vlan for reference
                while(lineList[0] != "!"):
                    line = next(switchConfigFile)
                    lineList = line.split()
                    
                    try:
                        vlansDict[vlanIndex]  # Test to see if the vlan is in the list
                    except KeyError:
                        # Vlan was not in the list, so add it before continuing to parse
                        vlansDict[vlanIndex] = {"interface":None,"description":"","ip":""}
                    
                    if lineList[0] == "description":
                        descriptionString = " ".join(lineList[1:])  # combine the rest of the line into a description
                        vlansDict[vlanIndex]["description"] = "{0}\n".format(descriptionString)
                    elif len(lineList) > 1:  # sometimes the line only has one word, so avoid an error
                        if (lineList[0] == "ip") and (lineList[1] == "address") and ("secondary" not in lineList):  # take the primary IP (sometimes there's a "secondary" ip address)
                            ipAddr = ipNetworkFromMask(lineList[2],lineList[3])
                            vlansDict[vlanIndex]["ip"] = str(ipAddr)


# STEP 4: Write down interface names and IPs (vlans dict needs an "interface name" field that is blank when not on the firewall)
with open(contextsFileName,"r") as contextFile:
    for line in contextFile:
        lineList = line.split()
        if len(lineList) > 0:  # skip empty lines
            if lineList[0] == "hostname":
                contextName = lineList[1]  # hostname == contextName
                try:
                    contextsDict[contextName]
                except KeyError:
                    contextsDict[contextName] = {"description":"","outside":[],"inside":[]}  # make a context if it's not already there (should be there but it might not be)
                    
                while(lineList[0] != "!"):
                    line = next(contextFile)  # skip ahead to the next section for interfaces
                    lineList = line.split()
                
                #interface processing
                while(lineList[0] != "passwd"):  # while not at the end of the current context configuration
                    line = next(contextFile)
                    lineList = line.split()
                    
                    if lineList[0] == "interface":
                        if lineList[1] == "outside":  # outside interfaces are always called "outside"
                            for vlan in contextsDict[contextName]["outside"]:
                                if lineList[1] == vlansDict[vlan]["interface"]:  # found a vlan with a matching interface
                                    while(lineList[0] != "!"):  # try to find an IP in the section
                                        line = next(contextFile)
                                        lineList = line.split()
                                        
                                        if lineList[0:2] == ["ip","address"]:  # found an IP address line
                                            vlansDict[vlan]["ip"] = str(ipNetworkFromMask(lineList[2],lineList[3]))  # write down the IP address
                                            break  # no need to keep looking for more IP addresses
                                    break  # got to the end of the section of a matching vlan, no need to keep looking in our for loop
                                    
                        elif lineList[1] == "BVI1":  # BVI1 interfaces are unique to transparent firewalls and are treated as though they are the IP information for the "inside" interface
                            for vlan in contextsDict[contextName]["inside"]:
                                if "inside" == vlansDict[vlan]["interface"]:  # found a vlan with a matching interface (BVI1's IP address is assigned to "inside")
                                    while(lineList[0] != "!"):  # try to find an IP in the section
                                        line = next(contextFile)
                                        lineList = line.split()
                                        
                                        if lineList[0:2] == ["ip","address"]:  # found an IP address line
                                            vlansDict[vlan]["ip"] = str(ipNetworkFromMask(lineList[2],lineList[3]))  # write down the IP address
                                            break  # no need to keep looking for more IP addresses
                                    break  # got to the end of the section of a matching vlan, no need to keep looking in our for loop
                                    
                        else:  # inside interfaces can be named anything, so they are the generalized case
                            for vlan in contextsDict[contextName]["inside"]:
                                if lineList[1] == vlansDict[vlan]["interface"]:  # found a vlan with a matching interface
                                    while(lineList[0] != "!"):  # try to find an IP in the section
                                        line = next(contextFile)
                                        lineList = line.split()
                                        
                                        if lineList[0:2] == ["ip","address"]:  # found an IP address line
                                            vlansDict[vlan]["ip"] = str(ipNetworkFromMask(lineList[2],lineList[3]))  # write down the IP address
                                            break  # no need to keep looking for more IP addresses
                                    break  # got to the end of the section of a matching vlan, no need to keep looking in our for loop


# STEP 5: Draw the tree
graph = 'graph {\nnode [shape=record]\nsplines=polyline\nswitch [color=blue,'  # top of graph
graph += 'label="{0}"]\n'.format(nameOfSwitch)  #split off the formatted part because python doesn't play well with literal brackets in strings

# Create the firewall block
graph += 'firewall [color=black,label="'  # standard start to the firewall
firewallBlock = ''
for context in contextsDict:
    contextBlock = '<{0}>{0}\\n{1}|'.format(context,contextsDict[context]["description"])
    firewallBlock += contextBlock
firewallBlock = firewallBlock[0:len(firewallBlock)-1]  # crop out the last "|" at the end of the string

firewallBlock += '"]\n'  # standard end
graph += firewallBlock  # add the block to the graph
graph += '\n'

# Create a list of all the vlans for iteration
vlanNameList = []
for vlanName in vlansDict:
    vlanNameList.append(vlanName)

# Iterate through the contexts
colors = ["#a85e00","#000000","#584f7a"]  # orange, black, and purple for colorblindness
colorIterator = 0
for context in contextsDict:
    # outside
    for vlan in contextsDict[context]["outside"]:
        repairedDesc = vlansDict[vlan]["description"][0:len(vlansDict[vlan]["description"])-1]  # remove the trailing newline before output
        repairedDesc = ''.join(repairedDesc.split('"'))  # cut out any quotations in the string
        connectionString = 'switch -- firewall:"{0}" [label="{1}\\n{2}\\n{3}" color="{4}" fontcolor="{4}"]\n'.format(context,vlan,vlansDict[vlan]["ip"],repairedDesc,colors[colorIterator])
        graph += connectionString
        colorIterator = (colorIterator+1)%3
        vlanNameList.pop(vlanNameList.index(vlan))  # remove the vlan since it's been drawn
    # inside
    for vlan in contextsDict[context]["inside"]:
        repairedDesc = vlansDict[vlan]["description"][0:len(vlansDict[vlan]["description"])-1]  # remove the trailing newline before output
        repairedDesc = ''.join(repairedDesc.split('"'))  # cut out any quotations in the string
        clientString = '{0} [label="{0}" color="blue"]\n'.format(vlan)
        connectionString = 'firewall:"{0}" -- "{1}" [label="{1}\\n{4}\\n{2}\\n{3}" color="{5}" fontcolor="{5}"]\n'.format(context,vlan,vlansDict[vlan]["ip"],repairedDesc,vlansDict[vlan]["interface"],colors[colorIterator])
        graph += clientString
        graph += connectionString
        colorIterator = (colorIterator+1)%len(colors)
        vlanNameList.pop(vlanNameList.index(vlan))  # remove the vlan since it's been drawn
    graph += "\n"

# Attach the remaining Vlans to the switch, in a subgoup (to make it more clear)
graph += 'subgraph cluster1{\nlabel="Non-Firewalled Vlans"\nstyle="dashed"\ncolor=blue\n\n'
maxStackSize = 10  # Condenses the vlans into "stacks" to make the graph less linear (for large networks, the picture generated becomes extremely wide and not very tall)
stackSize = 0  # current size of the visual stack
vlanStack = []  # Vlans to stack together
for vlan in vlanNameList:
    repairedDesc = vlansDict[vlan]["description"][0:len(vlansDict[vlan]["description"])-1]  # remove the trailing newline before output
    repairedDesc = ''.join(repairedDesc.split('"'))  # cut out any quotations in the string
    clientString = '{0} [label="{0}\\n{1}\\n{2}" color="blue"]\n'.format(vlan,vlansDict[vlan]["ip"],repairedDesc)
    connectionString = '"{0}" -- switch [color="{1}" fontcolor="{1}"]\n'.format(vlan,colors[colorIterator])
    graph += clientString
    graph += connectionString
    colorIterator = (colorIterator+1)%len(colors)
    graph += "\n"
    
    # Add another item to the stack
    stackSize+=1
    vlanStack.append(vlan)
    # Build the stack if we are at the max
    if stackSize == maxStackSize:
        graph += "\n"
        for i in range(1,stackSize):
            graph += '"{0}" -- "{1}" [style="invis"]\n'.format(vlanStack[i-1],vlanStack[i])
        vlanStack = []
        stackSize = 0
        graph += '\n\n'

# Build a partial stack if we ran out of vlans before finishing another stack
if stackSize > 1:
    graph += "\n"
    for i in range(1,stackSize):
        graph += '"{0}" -- "{1}" [style="invis"]\n'.format(vlanStack[i-1],vlanStack[i])
    vlanStack = []
    stackSize = 0
    graph += '\n\n'

graph += '}\n}\n'  # end of graph

# Render
src = graphviz.Source(graph,format='png')
src.render('output')
