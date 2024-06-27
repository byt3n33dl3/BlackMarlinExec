import os
import subprocess
import shutil

from PyQt5.QtWidgets import QWidget, QPushButton, QLabel, QTextEdit, QHBoxLayout, QVBoxLayout, QComboBox, QCheckBox, QMessageBox, QListWidget

from PyQt5.QtCore import  QEvent

class SprayingTab(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.layout = QVBoxLayout(self)

        # Note label
        self.noteLabel = QLabel("Note: To modify usernames or passwords, please go to the Management tab.")
        self.noteLabel.setStyleSheet("color: red;")  # Style note label text color
        self.layout.addWidget(self.noteLabel)
         # IP Addresses Dropdown
      
        
        # Container layout for usernames and passwords sections
        self.credentialsLayout = QHBoxLayout()

        # Vertical layout for usernames
        self.usernamesLayout = QVBoxLayout()
        self.usernamesLabel = QLabel("Usernames")
        self.usernamesLabel.setStyleSheet("color: green;")
        self.usernamesTextEdit = QTextEdit(self)
        self.usernamesTextEdit.setStyleSheet("color: yellow; background-color: black;")  # Set text color to yellow
        self.usernamesTextEdit.setReadOnly(True)  # Make the text box not modifiable
        #self.usernamesTextEdit.setPlaceholderText("Enter Usernames, one per line")
        self.usernamesLayout.addWidget(self.usernamesLabel)
        self.usernamesLayout.addWidget(self.usernamesTextEdit)

        # Vertical layout for passwords
        self.passwordsLayout = QVBoxLayout()
        self.passwordsLabel = QLabel("Passwords")
        self.passwordsLabel.setStyleSheet("color: green;")
        self.passwordsTextEdit = QTextEdit(self)
        self.passwordsTextEdit.setStyleSheet("color: yellow; background-color: black;")  # Set text color to yellow
        self.passwordsTextEdit.setReadOnly(True)  # Make the text box not modifiable
        #self.passwordsTextEdit.setPlaceholderText("Enter Passwords, one per line")
        self.passwordsLayout.addWidget(self.passwordsLabel)
        self.passwordsLayout.addWidget(self.passwordsTextEdit)


        # Add usernames and passwords layouts to the credentials container
        self.credentialsLayout.addLayout(self.usernamesLayout)
        self.credentialsLayout.addLayout(self.passwordsLayout)
        self.layout.addLayout(self.credentialsLayout)

        self.ipSelectionLayout = QHBoxLayout()
        self.ipLabel = QLabel("""
        Select IP Address:<br><br>
        <span style='color: yellow;'>=> </span>Select one or as many as you want.<br>
        <span style='color: yellow;'>=> </span>Please note that GoMapExec supports<br>more than one protocol at the same time, but CrackMapExic supports only one<br>
        <span style='color: yellow;'>=> </span>By default GoMapExec will scan all protocols together if no selection was made.<br>
        <span style='color: yellow;'>=> </span>When using CrackMapExec and nothing showing in the new open terminal <br>or showing error, make sure the host is UP.
        """)
        self.ipListWidget = QListWidget(self)
        self.ipListWidget.setSelectionMode(QListWidget.MultiSelection)  # Enable toggle selection without Ctrl
        self.ipSelectionLayout.addWidget(self.ipLabel)  # Add label to the horizontal layout
        self.ipSelectionLayout.addWidget(self.ipListWidget)  # Add list widget to the horizontal layout

        self.layout.addLayout(self.ipSelectionLayout)
        # Horizontal layout for the tool selection
        self.toolSelectionLayout = QHBoxLayout()
        self.toolLabel = QLabel("Choose tool:")
        self.toolComboBox = QComboBox(self)
        self.toolComboBox.addItems(["CrackMapExec", "GoMapExec"])
        self.updateDropdownStyle(self.toolComboBox)  # Apply the style

        self.toolComboBox.currentIndexChanged.connect(self.updateProtocolSelection)  
        self.executeButton = QPushButton("Execute", self)
        self.originalButtonText = self.executeButton.text()  
        self.toolSelectionLayout.addWidget(self.toolLabel)
        self.toolSelectionLayout.addWidget(self.toolComboBox)
        self.toolSelectionLayout.addWidget(self.executeButton)
        self.layout.addLayout(self.toolSelectionLayout)

        # Connect button click to executeCommand function
        self.executeButton.clicked.connect(self.executeCommand)

        # Protocol selection layout
        self.protocolLayout = QHBoxLayout()
        self.protocolLabel = QLabel("Protocol:")
        self.protocolLayout.addWidget(self.protocolLabel)
        self.protocols = {"rdp": QCheckBox("RDP"), "smb": QCheckBox("SMB"),
                          "ssh": QCheckBox("SSH"), "winrm": QCheckBox("WinRM")}
        for protocol in self.protocols.values():
            self.protocolLayout.addWidget(protocol)
        self.protocolCombo = QComboBox(self)
        self.protocolCombo.addItems(["SMB","WinRM"])
        self.protocolLayout.addWidget(self.protocolCombo)
        self.updateDropdownStyle(self.protocolCombo)

        # Hide protocolCombo initially; it will be shown based on tool selection
        self.protocolCombo.hide()

      

        # Make sure to call updateProtocolSelection at the end of initUI
        self.updateProtocolSelection(self.toolComboBox.currentIndex())
        # Add protocol layout to the main layout
        self.layout.addLayout(self.protocolLayout)

        # Initial UI setup
        self.updateProtocolSelection(self.toolComboBox.currentIndex())

     

        self.loadIPs()
        # Dropdown to choose between passwords or hashes
        self.credentialTypeLabel = QLabel("Credential Type:")
        self.credentialTypeCombo = QComboBox()
        self.credentialTypeCombo.addItems(["Passwords", "Hashes"])
        self.credentialTypeCombo.currentIndexChanged.connect(self.toggleCredentialInput)
        self.updateDropdownStyle(self.credentialTypeCombo)
        credentialTypeLayout = QHBoxLayout()
        credentialTypeLayout.addWidget(self.credentialTypeLabel)
        credentialTypeLayout.addWidget(self.credentialTypeCombo)
        self.layout.insertLayout(2, credentialTypeLayout)  # Insert this before credentialsLayout

        # Initialize the hashes text area here
        self.hashesTextEdit = QTextEdit(self)
        self.hashesTextEdit.setStyleSheet("color: yellow; background-color: black;")
        self.hashesTextEdit.setReadOnly(True)
        self.hashesTextEdit.hide()  # Start hidden, will be shown if 'Hashes' is selected
        self.passwordsLayout.addWidget(self.hashesTextEdit) 

        # Add the hashes text area to the layout
        # Assuming you want it in the same location as passwords, in passwordsLayout
        self.passwordsLayout.addWidget(self.hashesTextEdit)

    def toggleCredentialInput(self):
        # Show password area for passwords, hash area for hashes
        credential_type = self.credentialTypeCombo.currentText()
        if credential_type == "Passwords":
            self.passwordsTextEdit.show()
            self.hashesTextEdit.hide()
            self.passwordsLabel.setText("Passwords")  # Set label to "Passwords"
        else:
            self.passwordsTextEdit.hide()
            self.hashesTextEdit.show()
            self.passwordsLabel.setText("Hashes")  # Set label to "Hashes"
        # Load the appropriate credentials based on the selection
        self.loadUsernamesAndPasswords()

    def loadIPs(self):
        try:
            with open('/usr/share/adsuit/hosts.txt', 'r') as file:
                ips = file.read().strip().split('\n')  # Splitting by new line to get each IP
                self.ipListWidget.clear()  # Clearing existing items
                for ip in ips:
                    self.ipListWidget.addItem(ip)  # Add each IP to the list widget
        except FileNotFoundError:
            print("No /usr/share/adsuit/hosts.txt file found. Please ensure the /usr/share/adsuit/hosts.txt file is present.")




    def showEvent(self, event):
        super().showEvent(event)
        # Check if the tab is being shown, and if so, refresh the IP list
        if event.type() == QEvent.Show:
            self.ipListWidget.clear()  # Clear the existing list
            self.loadIPs()  # Load and repopulate the IP list
            self.loadUsernamesAndPasswords() 

    def loadUsernamesAndPasswords(self):
        # Load usernames from the file if it exists
        if os.path.exists('/usr/share/adsuit/usernames.txt'):
            with open('/usr/share/adsuit/usernames.txt', 'r') as f:
                usernames = f.read()
                self.usernamesTextEdit.setText(usernames)

        # Determine the type of credentials to load based on the dropdown selection
        credential_type = self.credentialTypeCombo.currentText()

        if credential_type == "Passwords":
            # Load passwords from the file if it exists
            if os.path.exists('/usr/share/adsuit/passwords.txt'):
                with open('/usr/share/adsuit/passwords.txt', 'r') as f:
                    passwords = f.read()
                    self.passwordsTextEdit.setText(passwords)
                self.passwordsTextEdit.show()
                self.hashesTextEdit.hide()
        elif credential_type == "Hashes":
            # Load hashes from the file if it exists
            if os.path.exists('/usr/share/adsuit/hashes.txt'):
                with open('/usr/share/adsuit/hashes.txt', 'r') as f:
                    hashes = f.read()
                    self.hashesTextEdit.setText(hashes)
                self.passwordsTextEdit.hide()
                self.hashesTextEdit.show()


    def updateDropdownStyle(self, comboBox):
        dropdownStyle = """
        QComboBox {
            border: 1px solid gray;
            border-radius: 3px;
            padding: 1px 18px 1px 3px;
            min-width: 6em;
        }
        QComboBox::drop-down {
            subcontrol-origin: padding;
            subcontrol-position: top right;
            width: 15px;
            border-left-width: 1px;
            border-left-color: darkgray;
            border-left-style: solid; 
            border-top-right-radius: 3px;
            border-bottom-right-radius: 3px;
        }
        QComboBox::down-arrow {
            image: url(/usr/share/icons/Adwaita/16x16/actions/arrow-down.png);
        }
        QComboBox::item {
            color: black;
            background-color: white;
        }
        QComboBox::item:hover {
            background-color: #2b579a;
            color: white;
        }
        """
        # Apply the style to the provided QComboBox
        comboBox.setStyleSheet(dropdownStyle)

    def updateProtocolSelection(self, index):
        # ... (existing updateProtocolSelection code)

        # Show/hide protocolCombo based on the tool selected
        tool = self.toolComboBox.currentText()
        if tool == "GoMapExec":
            # Hide the protocolCombo and show the checkboxes
            self.protocolCombo.hide()
            for protocol in self.protocols.values():
                protocol.show()
        elif tool == "CrackMapExec":
            # Show the protocolCombo and hide the checkboxes
            self.protocolCombo.show()
            for protocol in self.protocols.values():
                protocol.hide()

    def detect_terminal(self):
        # List of common terminals, ordered by preference
        terminals = ['qterminal', 'gnome-terminal', 'xterm', 'konsole']
        for terminal in terminals:
            if shutil.which(terminal):  # Checks if terminal is in PATH
                return terminal
        return None
    
    def executeCommand(self):
        selected_tool = self.toolComboBox.currentText()
        if selected_tool == "GoMapExec":
            self.executeGoMapExec()
        elif selected_tool == "CrackMapExec":
            self.executeCrackMapExec()

  
    def executeGoMapExec(self):
        # Retrieve the currently selected IPs from the ipListWidget
        selected_items = self.ipListWidget.selectedItems()
        selected_ips = [item.text() for item in selected_items]

        # Make sure there's at least one IP selected
        if not selected_ips:
            QMessageBox.warning(self, 'Error', 'Please select at least one IP address.')
            return

        # Collect selected protocols
        selected_protocols = [protocol for protocol, checkbox in self.protocols.items() if checkbox.isChecked()]
        protocols_str = '"' + ' '.join(selected_protocols) + '"' if selected_protocols else ''

        # Read domain, if applicable
        domain_str = ''
        try:
            with open('/usr/share/adsuit/domain.txt', 'r') as domain_file:
                domain = domain_file.read().strip()
                if domain:  # If domain is not empty
                    domain_str = f"-d {domain}"  # Use the -d flag for domain
        except FileNotFoundError:
            print("No /usr/share/adsuit/domain.txt file found or it's empty. Proceeding without domain.")

        # Prepare credential flags and check for hash count
        credential_flags = ''
        if self.credentialTypeCombo.currentText() == "Hashes":
            with open('/usr/share/adsuit/hashes.txt', 'r') as f:
                hashes = f.readlines()
                hashes = [h.strip() for h in hashes if h.strip()]  # Remove empty lines and strip whitespace
                if len(hashes) > 1:
                    QMessageBox.warning(self, 'Error', 'GoMapExec only supports one hash at a time.')
                    return  # Stop execution as more than one hash is not supported
                elif hashes:
                    credential_flags = f"-uf /usr/share/adsuit/usernames.txt -H {hashes[0]}"
                else:
                    QMessageBox.warning(self, 'Error', 'No hashes found in the file.')
                    return
        else:  # For passwords
            credential_flags = "-uf /usr/share/adsuit/usernames.txt -pf /usr/share/adsuit/passwords.txt"

        # Construct the command for all IPs
        command_list = ["/usr/share/adsuit/go_map_exec"]
        if protocols_str:  # Only add -pr and protocols if there are any selected
            command_list.extend(["-pr", protocols_str])
        command_list.extend([domain_str, credential_flags])  # Add domain and credential flags
        command_list.extend(selected_ips)  # Add all selected IPs at the end

        # Convert the command list to a string and execute it
        command_str = ' '.join(command_list).strip()
        print("Executing command:", command_str)  # Print command for debugging

        # Detect the terminal emulator on Kali Linux
        terminal = self.detect_terminal()
        if not terminal:
            QMessageBox.warning(self, 'Error', 'No known terminal found. Please install a terminal emulator.')
            return

        try:
            # Open a new terminal window using the detected terminal emulator and execute the command
            subprocess.Popen([terminal, '-e', 'bash', '-c', command_str + '; read -p "Press Enter to exit..."'])
        except Exception as e:
            QMessageBox.warning(self, 'Error', f'Failed to open terminal: {e}')


    def executeCrackMapExec(self):
        # Retrieve the currently selected IPs from the ipListWidget
        selected_items = self.ipListWidget.selectedItems()
        selected_ips = [item.text() for item in selected_items]

        # Make sure there's at least one IP selected
        if not selected_ips:
            QMessageBox.warning(self, 'Error', 'Please select at least one IP address.')
            return

        # Get selected protocol from the protocolCombo
        selected_protocol = self.protocolCombo.currentText().lower()

        # Read domain, if applicable
        domain_str = ''
        try:
            with open('/usr/share/adsuit/domain.txt', 'r') as domain_file:
                domain = domain_file.read().strip()
                domain_str = f"-d {domain}" if domain else ''
        except FileNotFoundError:
            print("No /usr/share/adsuit/domain.txt file found or it's empty. Proceeding without domain.")

        # Prepare credential flags based on the selected credential type
        credential_type = self.credentialTypeCombo.currentText()
        credential_flags = "-u /usr/share/adsuit/usernames.txt"  # Usernames flag is common to both cases

        if credential_type == "Hashes":
            # Assuming 'hashes.txt' contains multiple hashes, one per line
            hashes_path = '/usr/share/adsuit/hashes.txt'
            if not os.path.exists(hashes_path):
                QMessageBox.warning(self, 'Error', 'No hashes file found.')
                return
            credential_flags += f" -H {hashes_path}"
        else:  # For passwords
            passwords_path = '/usr/share/adsuit/passwords.txt'
            if not os.path.exists(passwords_path):
                QMessageBox.warning(self, 'Error', 'No passwords file found.')
                return
            credential_flags += f" -p {passwords_path}"

        
        # Construct the command using the selected protocol and credentials
        command = f"crackmapexec {selected_protocol} {' '.join(selected_ips)} {credential_flags} --continue-on-success {domain_str}"
        print("Executing command:", command)  # Print command for debugging

        # Use the detected terminal
        terminal = self.detect_terminal()
        if not terminal:
            QMessageBox.warning(self, 'Error', 'No known terminal found. Please install a terminal emulator.')
            return

        # The terminal command to keep the window open after executing crackmapexec
        terminal_command = f"{terminal} -e \"bash -c '{command}; bash'\""

        try:
            # Execute the terminal command
            subprocess.Popen(terminal_command, shell=True)
        except Exception as e:
            QMessageBox.warning(self, 'Error', f'Failed to open terminal: {e}')