import subprocess
import shutil

from blackmarlinexec.QtCore import QEvent, Qt
from blackmarlinexec.QtGui import QFont
from PyQt5.QtWidgets import QApplication, QVBoxLayout, QWidget, QPushButton, QLabel, QMessageBox, QHBoxLayout, QComboBox

QApplication.setFont(QFont('Arial', 10))

class SessionsTab(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(10)

        self.noteLabel = QLabel("Note: Please select the appropriate options below.")
        self.noteLabel.setStyleSheet("color: red;")
        self.noteLabel.setMaximumHeight(50)
        layout.addWidget(self.noteLabel)

        # Host Dropdown Field
        self.hostCombo = QComboBox()
        self.hostLabel = QLabel("Host:")
        hostLayout = QHBoxLayout()
        hostLayout.addWidget(self.hostLabel)
        hostLayout.addWidget(self.hostCombo)
        layout.addLayout(hostLayout)

        # Authentication Method Selection
        self.authMethodCombo = QComboBox()
        self.authMethodLabel = QLabel("Authentication Method:")
        self.authMethodCombo.addItems(["Password", "Hash"])
        authMethodLayout = QHBoxLayout()
        authMethodLayout.addWidget(self.authMethodLabel)
        authMethodLayout.addWidget(self.authMethodCombo)
        layout.addLayout(authMethodLayout)

        # Session Type Selection
        self.sessionTypeCombo = QComboBox()
        self.sessionTypeLabel = QLabel("Session Type:")
        self.sessionTypeCombo.addItems(["SMB", "WinRM", "RDP"])
        sessionTypeLayout = QHBoxLayout()
        sessionTypeLayout.addWidget(self.sessionTypeLabel)
        sessionTypeLayout.addWidget(self.sessionTypeCombo)
        layout.addLayout(sessionTypeLayout)

        # Username Dropdown Field
        self.usernameCombo = QComboBox()
        self.usernameLabel = QLabel("Username:")
        usernameLayout = QHBoxLayout()
        usernameLayout.addWidget(self.usernameLabel)
        usernameLayout.addWidget(self.usernameCombo)
        layout.addLayout(usernameLayout)

        # Password/Hash Dropdown Field
        self.passwordCombo = QComboBox()
        self.passwordLabel = QLabel("Password/Hash:")
        passwordLayout = QHBoxLayout()
        passwordLayout.addWidget(self.passwordLabel)
        passwordLayout.addWidget(self.passwordCombo)
        layout.addLayout(passwordLayout)

        # Connect Button
        self.connectButton = QPushButton("Connect")
        self.connectButton.clicked.connect(self.connectSession)
        layout.addWidget(self.connectButton, alignment=Qt.AlignCenter)

        self.setLayout(layout)
        self.updateDropdownStyle()
        self.loadHosts()
        self.loadUsernames()
        self.loadCredentials('passwords')
        self.authMethodCombo.currentIndexChanged.connect(self.onAuthMethodChange)

    def showEvent(self, event):
        super().showEvent(event)

        if event.type() == QEvent.Show:
            self.loadHosts()
            self.onAuthMethodChange()
            self.loadUsernames()
     

    def loadHosts(self):
        # Clear existing items
        self.hostCombo.clear()  
        try:
            with open('/usr/share/adsuit/hosts.txt', 'r') as file:
                # Read each line as a host and strip to remove newline characters
                hosts = [line.strip() for line in file.readlines() if line.strip()]
                for host in hosts:
                    self.hostCombo.addItem(host)  # Add each host to the combo box
        except FileNotFoundError:
            QMessageBox.warning(self, 'Error', 'Could not find the hosts.txt file.')


    def loadCredentials(self, credential_type):
        """
        Load credentials based on the provided type.
        credential_type can be 'passwords' or 'hashes'
        """
        filename = f"/usr/share/adsuit/{credential_type}.txt"
        self.passwordCombo.clear()  # Clear the dropdown

        try:
            with open(filename, 'r') as file:
                credentials = file.read().strip().split('\n')
                self.passwordCombo.addItems(credentials)
        except FileNotFoundError:
            QMessageBox.warning(self, 'Error', f'Could not find the {filename} file.')

    def loadUsernames(self):
        """
        Load usernames from a file.
        """
        username_filename = "/usr/share/adsuit/usernames.txt"  # Adjust the filename as needed
        self.usernameCombo.clear()  # Clear the dropdown

        try:
            with open(username_filename, 'r') as file:
                usernames = file.read().strip().split('\n')
                self.usernameCombo.addItems(usernames)
        except FileNotFoundError:
            QMessageBox.warning(self, 'Error', f'Could not find the {username_filename} file.')        
    def onAuthMethodChange(self):
        auth_method = self.authMethodCombo.currentText().lower()
        if auth_method == "password":
            self.loadCredentials('passwords')
        elif auth_method == "hash":
            self.loadCredentials('hashes')

    def populateCredentialsDropdown(self):
        # Clear existing items
        self.usernameCombo.clear()
        self.passwordCombo.clear()

        # Add credentials to the dropdowns
        for username, password in self.user_credentials:
            self.usernameCombo.addItem(username)
            self.passwordCombo.addItem(password)
    
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
        # Apply the style to each QComboBox
        self.authMethodCombo.setStyleSheet(dropdownStyle)
        self.sessionTypeCombo.setStyleSheet(dropdownStyle)
        self.usernameCombo.setStyleSheet(dropdownStyle)
        self.passwordCombo.setStyleSheet(dropdownStyle)
        self.hostCombo.setStyleSheet(dropdownStyle)



    def detect_terminal(self):
        # List of common terminals, ordered by preference
        terminals = ['qterminal', 'gnome-terminal', 'xterm', 'konsole']
        for terminal in terminals:
            if shutil.which(terminal):  # Checks if terminal is in PATH
                return terminal
        return None

    def connectSession(self):
        self.connectButton.setText("Connecting...")
        self.connectButton.setEnabled(False)

        # Now using selected_host from the dropdown
        selected_host = self.hostCombo.currentText()

        # Rest of your connection logic using selected_host
        username = self.usernameCombo.currentText()
        credential = self.passwordCombo.currentText()
        auth_method = self.authMethodCombo.currentText()
        session_type = self.sessionTypeCombo.currentText()

        if session_type == "SMB":
            if auth_method == "Password":
                command = f"impacket-psexec {username}:{credential}@{selected_host}"
            else:  # Using NTLM hash
                command = f"impacket-psexec -hashes 00000000000000000000000000000000:{credential} {username}@{selected_host}"
        elif session_type == "WinRM":
            if auth_method == "Password":
                command = f"evil-winrm -u {username} -p {credential} -i {selected_host}"
                
            else:  # Using hash
                command = f"evil-winrm -u {username} -H {credential} -i {selected_host}"
        elif session_type == "RDP":
        # Handle RDP connection separately using xfreerdp
                command = f"xfreerdp /u:{username} /p:{credential} /v:{selected_host}"       
        try:
            # Detect the terminal emulator on Kali Linux
            terminal = self.detect_terminal()
            if not terminal:
                QMessageBox.warning(self, 'Error', 'No known terminal found. Please install a terminal emulator.')
                self.resetConnectButton()  # Reset the button state
                return

            # Open a new terminal window using the detected terminal emulator and execute the command
          
            subprocess.Popen([terminal, '-e', 'bash', '-c', command + '; read -p "Press Enter to exit..."'])
            self.resetConnectButton()
        except Exception as e:
            QMessageBox.warning(self, 'Error', f'Failed to open terminal: {e}')
            self.resetConnectButton()  # Reset the button state

    def resetConnectButton(self):
        self.connectButton.setText("Connect")
        self.connectButton.setEnabled(True)
