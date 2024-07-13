from blackmarlinexec.QtCore import  Qt
from blackmarlinexec.QtGui import QFont, QPixmap
from blackmarlinexec.QtWidgets import (
    QApplication, QMainWindow, QTabWidget, QVBoxLayout, QWidget, QLabel, QGridLayout, QHBoxLayout
)
from SessionsTab import SessionsTab
from HostsTab import HostsTab
from UserManagementTab import UserManagementTab
from SprayingTab import SprayingTab
from PivotingTab import PivotingTab
from Attacks import Attacks

QApplication.setFont(QFont('Arial', 10))


class AboutTab(QWidget):
    def __init__(self):
        super().__init__()

        # Main layout - Horizontal layout to split into two parts
        mainLayout = QHBoxLayout(self)

         # Left part: Information
        leftLayout = QVBoxLayout()

        # Developed by label
        developedByLabel = QLabel("Developed by:")
        developedByLabel.setAlignment(Qt.AlignCenter)  # Center the label
        leftLayout.addWidget(developedByLabel)  # Add the label to the layout
        developedByLabel.setFixedSize(400, 40)
        # Developed by image
        developedByImageLabel = QLabel()
        developedByPixmap = QPixmap('/usr/share/adsuit/hacker.png')  # Replace with the path to your image
        developedByImageLabel.setPixmap(developedByPixmap.scaled(300, 300, Qt.KeepAspectRatio))  # Scale the image
        developedByImageLabel.setAlignment(Qt.AlignCenter)  # Center the image
        leftLayout.addWidget(developedByImageLabel)  # Add the image label to the layout

        # Information grid
        gridLayout = QGridLayout()
        headerFont = QFont('Arial', 12, QFont.Bold)

       # Name
        nameLabel = QLabel("Name:")
        nameLabel.setFont(headerFont)
        nameValue = QLabel("Tonee Marqus")
        nameValue.setTextInteractionFlags(Qt.TextSelectableByMouse)  # Make the text selectable
        gridLayout.addWidget(nameLabel, 0, 0)
        gridLayout.addWidget(nameValue, 0, 1)

        # Email
        emailLabel = QLabel("Email:")
        emailLabel.setFont(headerFont)
        emailValue = QLabel("toneemarqus@gmail.com")
        emailValue.setTextInteractionFlags(Qt.TextSelectableByMouse)  # Make the text selectable
        gridLayout.addWidget(emailLabel, 1, 0)
        gridLayout.addWidget(emailValue, 1, 1)

        # GitHub
        githubLabel = QLabel("GitHub:")
        githubLabel.setFont(headerFont)
        githubValue = QLabel("<a href='https://github.com/toneemarqus'>toneemarqus</a>")
        githubValue.setOpenExternalLinks(True)
        gridLayout.addWidget(githubLabel, 2, 0)
        gridLayout.addWidget(githubValue, 2, 1)

        # Medium
        mediumLabel = QLabel("Medium:")
        mediumLabel.setFont(headerFont)
        mediumValue = QLabel("<a href='https://medium.com/@toneemarqus'>@toneemarqus</a>")
        mediumValue.setOpenExternalLinks(True)
        gridLayout.addWidget(mediumLabel, 3, 0)
        gridLayout.addWidget(mediumValue, 3, 1)

        # Profession
        professionLabel = QLabel("Profession:")
        professionLabel.setFont(headerFont)
        professionValue = QLabel("Penetration Tester")
        gridLayout.addWidget(professionLabel, 4, 0)
        gridLayout.addWidget(professionValue, 4, 1)

        leftLayout.addLayout(gridLayout)

         # Right part: Image and AD Suit label
        rightLayout = QVBoxLayout()

        # AD Suit label
        adSuitLabel = QLabel("AD Suit:")
        adSuitLabel.setAlignment(Qt.AlignCenter)  # Center the label
        rightLayout.addWidget(adSuitLabel)  # Add the label to the layout

        # Image
        imageLabel = QLabel()
        pixmap = QPixmap('/usr/share/adsuit/icon.jpg')  # Replace with the path to your image
        imageLabel.setPixmap(pixmap.scaled(800, 700, Qt.KeepAspectRatio))  # Scale the image
        imageLabel.setAlignment(Qt.AlignCenter)  # Center the image
        rightLayout.addWidget(imageLabel)

        # Add left and right layouts to the main layout
        mainLayout.addLayout(leftLayout)
        mainLayout.addLayout(rightLayout)

        self.setLayout(mainLayout)


class MyTableWidget(QWidget):
    def __init__(self, parent):
        super(QWidget, self).__init__(parent)
        self.layout = QVBoxLayout(self)

        # Initialize tab screen
        self.tabs = QTabWidget()

        # Create the tabs
        self.hostsTab = HostsTab() # Create HostsTab first
        self.userManagementTab = UserManagementTab()
        self.sessionsTab = SessionsTab()
        self.sprayingTab = SprayingTab()
        self.pivotingTab = PivotingTab()
        self.Attacks = Attacks()
        self.aboutTab = AboutTab()
        # Add tabs in the specified order, starting with HostsTab
        self.tabs.addTab(self.hostsTab, "    Hosts    ") # Add Hosts tab first
        self.tabs.addTab(self.userManagementTab, "      UserManagement      ")
        self.tabs.addTab(self.sessionsTab, "    Sessions    ")
        self.tabs.addTab(self.sprayingTab, "    Spraying    ")
        self.tabs.addTab(self.pivotingTab, "    Pivoting    ")
        self.tabs.addTab(self.Attacks, "    Attacks    ")
        self.tabs.addTab(self.aboutTab, "    About    ")
        # Add tabs to widget
        self.layout.addWidget(self.tabs)
        self.setLayout(self.layout)
class ADSuite(QMainWindow):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('AD Suite')
        self.setGeometry(400, 200, 1200, 800)  # Set initial position and size

        # Set the fixed size to the initial size to prevent maximizing
        self.setFixedSize(1200, 800)
        self.table_widget = MyTableWidget(self)
        self.setCentralWidget(self.table_widget)

        self.setStyleSheet("""
            QMainWindow {
                background-color: #2b2b2b;
            }
            QTabWidget::pane {
                border: 4px solid #444;
                background: #2b2b2b;
            }
           QTabBar::tab {
                background: rgb(255, 102, 51); /* Same as button color */
                color: rgb(0, 0, 0); /* Black text for contrast */
                font-weight: bold; /* Make the font bold */
                padding: 8px;
                margin: 2px;
                border: 1px solid #444;
                border-bottom: none;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                font-size: 16px;
            }

            QTabBar::tab:selected {
                background: rgb(230, 92, 46); /* Slightly darker for the selected tab */
                color: rgb(255, 255, 255); /* White text for the selected tab */
                font-weight: bold; /* Ensure the font is bold */
            }

            QTabBar::tab:hover {
                background: rgb(255, 114, 71); /* A lighter orange for hover */
                color: rgb(0, 0, 0);
            }
            QLabel, QPushButton, QLineEdit, QTextEdit, QComboBox, QListWidget {
                background-color: #313335;
                color: #a9b7c6;
                border: 1px solid #555;
                padding: 5px;
                margin: 5px;
                border-radius: 5px;
            }
            QPushButton {
                background-color: rgb(255, 102, 51); /* Accent color for important buttons only */
                color: rgb(0, 0, 0); /* Black text for better legibility */
                font: bold 14px 'Arial';
                min-width: 10em;
                padding: 10px;
                border: none; /* Cleaner look without borders */
                border-radius: 5px; /* Rounded corners */
            }
            QPushButton:hover {
                background-color: rgb(230, 92, 46);
            }
            QPushButton:pressed {
                background-color: #3c3f41;
            }
            QPushButton:disabled {
                background-color: #393c3e;
                color: #575b5e;
            }
            QListWidget {
                border-radius: 5px;
            }
        """)



