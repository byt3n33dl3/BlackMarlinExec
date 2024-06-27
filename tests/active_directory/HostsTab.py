from PyQt5.QtCore import QTimer
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QVBoxLayout, QTextEdit

QApplication.setFont(QFont('Arial', 10))

class HostsTab(QWidget):
    def __init__(self):
        super().__init__()
        self.originalButtonText = "Save Hosts & Domain"  # Define originalButtonText before calling initUI
        self.initUI()
        self.loadHosts()
        self.loadDomain()

    def initUI(self):
        self.layout = QVBoxLayout(self)

        # Section for entering host IPs
        self.hostTextEdit = QTextEdit()
        self.hostTextEdit.setPlaceholderText("Enter host IPs, one per line")
        self.hostTextEdit.textChanged.connect(self.saveAll)  # Auto-save when text changes
        self.layout.addWidget(self.hostTextEdit)

        # Section for entering the domain
        self.domainTextEdit = QTextEdit()
        self.domainTextEdit.setPlaceholderText("Enter domain here")
        self.domainTextEdit.textChanged.connect(self.saveAll)  # Auto-save when text changes
        self.domainTextEdit.textChanged.connect(self.validateDomain)

        self.layout.addWidget(self.domainTextEdit)

        # Save Button
        self.saveButton = QPushButton(self.originalButtonText)
        self.layout.addWidget(self.saveButton)

        # Clear Button
        self.clearButton = QPushButton("Clear All")
        self.clearButton.clicked.connect(self.clearAll)
        self.layout.addWidget(self.clearButton)

    def saveAll(self):
        self.saveHosts()
        self.saveDomain()

        # Change the save button text and style to indicate saving
        self.saveButton.setText("Saved!")
        self.saveButton.setStyleSheet("background-color: green; color: white;")
        QTimer.singleShot(500, self.resetSaveButton)  
    def resetSaveButton(self):
        # Reset the button's text and style back to the original
        self.saveButton.setText(self.originalButtonText)
        self.saveButton.setStyleSheet("")    

    def resetSaveButton(self):
        # Reset the button's text and style back to the original
        self.saveButton.setText(self.originalButtonText)
        self.saveButton.setStyleSheet("")

    def clearAll(self):
        self.hostTextEdit.clear()
        self.domainTextEdit.clear()
        self.saveAll()  # Save empty data to both files

    def saveHosts(self):
        hosts = self.hostTextEdit.toPlainText().strip()
        with open('/usr/share/adsuit/hosts.txt', 'w') as file:
            file.write(hosts)


    def validateDomain(self):
        # Get the current text from domainTextEdit
        domain_text = self.domainTextEdit.toPlainText()
        lines = domain_text.split('\n')
        if len(lines) > 1:  # If there's more than one line, keep only the first one
            self.domainTextEdit.textChanged.disconnect(self.validateDomain)  # Disconnect to avoid recursive loop
            self.domainTextEdit.setText(lines[0])  # Set text to only the first line
            self.domainTextEdit.textChanged.connect(self.validateDomain)  # Reconnect the signal
    

    def saveDomain(self):
        domain = self.domainTextEdit.toPlainText().strip()
        print("Saving domain:", domain)  # Debugging line
        with open('/usr/share/adsuit/domain.txt', 'w') as file:
            file.write(domain)

    def loadHosts(self):
        try:
            with open('/usr/share/adsuit/hosts.txt', 'r') as file:
                hosts = file.read()
                self.hostTextEdit.textChanged.disconnect(self.saveAll)  # Disconnect the signal
                self.hostTextEdit.setText(hosts)
                self.hostTextEdit.textChanged.connect(self.saveAll)  # Reconnect the signal
        except FileNotFoundError:
            self.saveHosts()  # Create the file if it doesn't exist


    def loadDomain(self):
        try:
            with open('/usr/share/adsuit/domain.txt', 'r') as file:
                domain = file.read()
                self.domainTextEdit.textChanged.disconnect(self.saveAll)  # Disconnect the signal
                self.domainTextEdit.setText(domain)
                self.domainTextEdit.textChanged.connect(self.saveAll)  # Reconnect the signal
        except FileNotFoundError:
            self.saveDomain()  # Create the file if it doesn't exist