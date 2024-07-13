import sys

from blackmarlinexec.QtCore import QTimer
from blackmarlinexec.QtGui import QFont
from blackmarlinexec.QtWidgets import QApplication, QWidget, QPushButton, QLabel, QMessageBox, QTextEdit, QHBoxLayout, QVBoxLayout

QApplication.setFont(QFont('Arial', 10))


class UserManagementTab(QWidget):
    def __init__(self):
        super().__init__()
        self.originalButtonText = "Save Credentials"  # Define originalButtonText before calling initUI
        self.initUI()  # Now initUI can safely use self.originalButtonText
        self.loadCredentials()


    def initUI(self):
        self.layout = QVBoxLayout(self)

        # Horizontal layout to contain both the usernames and passwords sections
        self.credentialsLayout = QHBoxLayout(self)

        # Vertical layout for usernames
        self.usernamesLayout = QVBoxLayout()
        self.usernameLabel = QLabel("Usernames:")
        self.usernameLabel.setStyleSheet("color: green;")
        self.usernamesTextEdit = QTextEdit()
        self.usernamesTextEdit.setPlaceholderText("Enter usernames, one per line")
        self.usernamesTextEdit.textChanged.connect(self.saveCredentials)  # Auto-save when text changes
        self.usernamesLayout.addWidget(self.usernameLabel)
        self.usernamesLayout.addWidget(self.usernamesTextEdit)

        # Add usernames layout to the credentials container
        self.credentialsLayout.addLayout(self.usernamesLayout)

        # Vertical layout for passwords
        self.passwordsLayout = QVBoxLayout()
        self.passwordLabel = QLabel("Passwords:")
        self.passwordLabel.setStyleSheet("color: green;")
        self.passwordsTextEdit = QTextEdit()
        self.passwordsTextEdit.setPlaceholderText("Enter passwords, one per line")
        self.passwordsTextEdit.textChanged.connect(self.saveCredentials)  # Auto-save when text changes
        self.passwordsLayout.addWidget(self.passwordLabel)
        self.passwordsLayout.addWidget(self.passwordsTextEdit)

        # Add passwords layout to the credentials container
        self.credentialsLayout.addLayout(self.passwordsLayout)

        # Add the credentials container to the main layout
        self.layout.addLayout(self.credentialsLayout)

        self.hashesLayout = QVBoxLayout()
        self.hashesLabel = QLabel("Hashes:")
        self.hashesLabel.setStyleSheet("color: green;")
        self.hashesTextEdit = QTextEdit()
        self.hashesTextEdit.setPlaceholderText("Enter hashes, one per line")
        self.hashesTextEdit.textChanged.connect(self.saveCredentials)  # Auto-save when text changes
        self.hashesLayout.addWidget(self.hashesLabel)
        self.hashesLayout.addWidget(self.hashesTextEdit)

        # Add hashes layout to the credentials container
        self.credentialsLayout.addLayout(self.hashesLayout)

        # Add the credentials container to the main layout
        self.layout.addLayout(self.credentialsLayout)

        # Save Button
        self.saveButton = QPushButton(self.originalButtonText)
        self.layout.addWidget(self.saveButton)

        # Clear Button
        self.clearButton = QPushButton("Clear All")
        self.clearButton.clicked.connect(self.clearCredentials)
        self.layout.addWidget(self.clearButton)

    def saveCredentials(self):
        usernames = self.usernamesTextEdit.toPlainText().strip().split('\n')
        passwords = self.passwordsTextEdit.toPlainText().strip().split('\n')
        hashes = self.hashesTextEdit.toPlainText().strip().split('\n')
        # Save each set of credentials to its respective file
        self.saveCredentialsToFile(usernames, '/usr/share/adsuit/usernames.txt')
        self.saveCredentialsToFile(passwords, '/usr/share/adsuit/passwords.txt')
        self.saveCredentialsToFile(hashes, '/usr/share/adsuit/hashes.txt')

        # Temporarily change the button text and style to indicate saving
        self.saveButton.setText("Saved!")
        self.saveButton.setStyleSheet("background-color: green; color: white;")
        QTimer.singleShot(2000, self.resetSaveButton)  

    def resetSaveButton(self):
        # Reset the button's text and style back to the original
        self.saveButton.setText(self.originalButtonText)
        self.saveButton.setStyleSheet("")

    def clearCredentials(self):
        self.usernamesTextEdit.clear()
        self.passwordsTextEdit.clear()
        self.saveCredentialsToFile([], '/usr/share/adsuit/usernames.txt')  # Save an empty list to the usernames file
        self.saveCredentialsToFile([], '/usr/share/adsuit/passwords.txt')  # Save an empty list to the passwords file
        QMessageBox.information(self, 'Cleared', 'All credentials have been cleared!')

    def saveCredentialsToFile(self, data, filename):
        with open(filename, 'w') as file:
            file.write("\n".join(data))

    def loadCredentials(self):
        try:
            with open('/usr/share/adsuit/usernames.txt', 'r') as usernames_file:
                usernames = usernames_file.read().split('\n')

            with open('/usr/share/adsuit/passwords.txt', 'r') as passwords_file:
                passwords = passwords_file.read().split('\n')

            with open('/usr/share/adsuit/hashes.txt', 'r') as hashes_file:
                hashes = hashes_file.read().split('\n')

            # Join usernames and passwords with newline character
            usernames_text = "\n".join(usernames)
            passwords_text = "\n".join(passwords)
            hashes_text = "\n".join(hashes)
            self.hashesTextEdit.setText(hashes_text)
            self.usernamesTextEdit.setText(usernames_text)
            self.passwordsTextEdit.setText(passwords_text)

        except FileNotFoundError:
            self.saveCredentialsToFile([], '/usr/share/adsuit/usernames.txt')
            self.saveCredentialsToFile([], '/usr/share/adsuit/passwords.txt')
