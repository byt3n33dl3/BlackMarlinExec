import requests
import json
import re
import os
from os import system
import urllib.request
import shutil
from mainAPI import main
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary

def help():
    print('\033[4mOneDrive Query Misc. Commands\033[0m')
    print('r: Root Dir\nb: Previous Dir\nq: Quit\n')
    print('To download a file, simply choose the number for the file.\n')
    print("Files are downloaded to the 'output' folder in the framework directory.\n")
    input('Press ENTER key to continue...')

#-----------Auth Headers------------------------------
def getHeaders(user):
    tokenLibrary = openTokenLibrary()
    headers={'Authorization': 'Bearer ' + tokenLibrary[user]['access_token'], 'Content-type': 'application/json'}
    return headers

#------------Drives API-------------------------------
def drivesAPI(headers):

    graph_data = requests.get('https://graph.microsoft.com/v1.0/me/drives', headers=headers).json()
    return graph_data

#---------Drive Contents API---------------------------
def driveContentsAPI(headers, driveID):

    graph_data = requests.get(f"https://graph.microsoft.com/v1.0/drives/{driveID}/root/children", headers=headers).json()
    return graph_data

#---------Folders/Files API----------------------------
def contentItemsAPI(headers, contentID):

    graph_data = requests.get(f"https://graph.microsoft.com/v1.0/me/drive/items/{contentID}/children", headers=headers).json()
    return graph_data
    
#-----------Get Drives---------------------------------
def getDrives(headers, user):

    while True:
        availableDrives = drivesAPI(headers)

        print('\033[4mAvailable Drives:\033[0m')
        try:
            for i in range(0, len(availableDrives['value'])):
                print(f"{i}) {availableDrives['value'][i]['driveType']} \n")
            driveChoice = input("Choose drive ('h' for help): ")
        
        #Bad permissions or token
        except:
            print('[-] Bad Permissions or user doesn\'t have OneDrive')
            input('')
            system('clear')
            main(user)

        if driveChoice.isnumeric():
            driveChoice = int(driveChoice)
            system('clear')
        
        elif not driveChoice.isnumeric():
            if driveChoice == 'q' or driveChoice == 'b':
                system('clear')
                main(user)

            elif driveChoice == 'h':
                system('clear')
                help()
                system('clear')
                continue 

            else:
                system('clear')
                print('Invalid Choice\n')
                continue

        try:
            driveID = str(availableDrives['value'][driveChoice]['id'])
            driveName = availableDrives['value'][driveChoice]['driveType']
            system('clear')
            break
        except:
            print('Invalid Choice\n')
            continue

    return driveID, driveName

#---------Get Drive Contents--------------------------
def getDriveContents(headers, driveID, driveName, user, itemTitle):

    while True:
        driveContents = driveContentsAPI(headers, driveID)

        print(f'[DIR]: {driveName}/\n')
        for i in range(0, len(driveContents['value'])):
            print(f"{i}) {driveContents['value'][i]['name']}")
        
        contentChoice = input('\nChoose item:')
        if contentChoice.isnumeric():
            contentChoice = int(contentChoice)
            
            try:
                contentID = str(driveContents['value'][contentChoice]['id'])
                contentName = str(driveContents['value'][contentChoice]['name'])

                #if filename, write to output folder
                fileRegex = re.search(r'\w*\.\w*', contentName)
                if fileRegex:
                    downloadURL = str(driveContents['value'][contentChoice]['@microsoft.graph.downloadUrl'])
                    
                    curDirectory = os.path.abspath(__file__)
                    mainDirectory = os.path.dirname(os.path.dirname(curDirectory))
                    outputDir = f'{mainDirectory}/output'
                    
                    if os.path.exists(outputDir):
                        with urllib.request.urlopen(downloadURL) as response, open(f'{outputDir}/{contentName}', 'wb') as out_file:
                            shutil.copyfileobj(response, out_file)
                    else:
                        os.mkdir(outputDir)
                        with urllib.request.urlopen(downloadURL) as response, open(f'{outputDir}/{contentName}', 'wb') as out_file:
                            shutil.copyfileobj(response, out_file)
                    
                    input(f"[+] File written to 'output/{contentName}'")
                    system('clear')
                    continue
                system('clear')
                break

            except:
                system('clear')
                print('Invalid Choice\n')
                continue
        
        #Other commands
        elif not contentChoice.isnumeric():
            #break
            if contentChoice == 'b':
                system('clear')
                driveID = getDrives(headers, user)[0]
                continue
            
            #quit
            elif contentChoice == 'q':
                system('clear')
                main(user)

            #help
            elif contentChoice == 'h':
                system('clear')
                help()
                system('clear')
                continue 

            else:
                system('clear')
                print('Invalid Choice\n')
                continue

    return contentID, contentName
    

#--------Get Subfolders/Files (items)-------------------------
def getItems(headers, user, itemID, itemTitle, driveID, driveName):

    #keep track of directories
    parentDictionary={}
    itemTitleList = []

    while True:

        contentItems = contentItemsAPI(headers, itemID)
        
        print(f"[DIR]: {driveName}/{itemTitle}{''.join(itemTitleList)}/\n")
        for i in range(0, len(contentItems['value'])):
            print(f"{i}) {contentItems['value'][i]['name']}")
            
        
        itemChoice = input('\nChoose item:')
        if itemChoice.isnumeric():
            itemChoice = int(itemChoice)

            try:
                itemName = str(contentItems['value'][itemChoice]['name'])

            except:
                system('clear')
                print('Invalid Choice\n')
                
                continue
    
            #if filename, write to output folder
            fileRegex = re.search(r'\w*\.\w*', itemName)
            if fileRegex:
                downloadURL = str(contentItems['value'][itemChoice]['@microsoft.graph.downloadUrl'])
                
                curDirectory = os.path.abspath(__file__)
                mainDirectory = os.path.dirname(os.path.dirname(curDirectory))
                outputDir = f'{mainDirectory}/output'
                
                if os.path.exists(outputDir):
                    with urllib.request.urlopen(downloadURL) as response, open(f'{outputDir}/{itemName}', 'wb') as out_file:
                        shutil.copyfileobj(response, out_file)
                else:
                    os.mkdir(outputDir)
                    with urllib.request.urlopen(downloadURL) as response, open(f'{outputDir}/{itemName}', 'wb') as out_file:
                        shutil.copyfileobj(response, out_file)
                
                input(f"[+] File written to 'output/{itemName}'")
                system('clear')
                continue
            
            #if folder, open
            else:
                system('clear')
                parentID = itemID
                itemID = str(contentItems['value'][itemChoice]['id'])

                itemTitleList.append(f"/{itemName}")
                parentDictionary.update({itemID: parentID})
            

        elif not itemChoice.isnumeric():
            if itemChoice == 'b':
                system('clear')
                #go to parent directory
                try:
                    itemID = parentDictionary[itemID]
                    itemTitleList = itemTitleList[:-1]
                #if error go to root directory
                except:
                    itemID, itemTitle = getDriveContents(headers, driveID, driveName, user, itemTitle)
                continue
            
            elif itemChoice == 'q':
                system('clear')
                main(user)

            #r (Root), restart from root dir, reset lists
            elif itemChoice == 'r':
                system('clear')
                itemID, itemTitle = getDriveContents(headers, driveID, driveName, user, itemTitle)
                itemTitleList=[]

            elif itemChoice == 'h':
                system('clear')
                help()
                system('clear')
                continue 

            else:
                system('clear')
                print('Invalid Choice\n')
                continue

    return itemName, itemID

#---------------Main-----------------
def sendQuery(user):
    
    #set auth headers for API
    headers = getHeaders(user)

    #get drives
    driveChoice = getDrives(headers, user)
    driveID = driveChoice[0]
    driveName = driveChoice[1]

    #get contents
    contentChoice = getDriveContents(headers, driveID, driveName, user, None)
    itemID = contentChoice[0]
    itemTitle = contentChoice[1]
    
    #get folders/files
    getItems(headers, user, itemID, itemTitle, driveID, driveName)