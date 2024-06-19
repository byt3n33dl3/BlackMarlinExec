import requests
import json
import base64
import os
from os import system
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary

#-----------Auth Headers------------------------------
def getHeaders(user):
    tokenLibrary = openTokenLibrary()
    headers={'Authorization': 'Bearer ' + tokenLibrary[user]['access_token'], 'Content-type': 'application/json'}
    return headers


#------------Search Email------------------------------------------

def searchEmail(headers, user):

    searchQuery = str(input('Enter search term: '))

    if searchQuery == 'q':
        return None

    system('clear')

    #JSON for request
    data={
    "requests": [
        {
        "entityTypes": [
            "microsoft.graph.message"
        ],
        "query": {
            "query_string": {
            "query": searchQuery
            }
        },
        "from": 0,
        "size": 25
        }
      ]
    }

    #send API call
    emailResults = requests.post('https://graph.microsoft.com/beta/search/query', json=data, headers=headers).json()
    
    #check if successful
    try:
        if emailResults['error']['message'] == 'Error authenticating with resource':
            print('[-] Error authenticating with resource. Likely not a work or school account.\n')
            input('Press ENTER to continue...')
            return

        else: 
            print(f"[-] {emailResults['error']['message']}\n")
            input('Press ENTER to continue...')
            return

    except:
        #If successful: print/choose results
        try:
            for i in range(0, len(emailResults['value'][0]['hitsContainers'][0]['hits'])):
                
                #skip if sender/receiver is EXCHANGELABS
                if 'O=EXCHANGELABS' in emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['sender']['emailAddress']['address']:
                    continue
                
                else:
                    print(f"{i}) Subject: {emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['subject']}\n \
                                Received: {emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['receivedDateTime'].replace('T', ' ')[:-1]}\n \
                                Has Attachment: {emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['hasAttachments']}\n \
                                Sender: {emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['sender']['emailAddress']['address']}\n \
                                From: {emailResults['value'][0]['hitsContainers'][0]['hits'][i]['_source']['from']['emailAddress']['address']}\n ")
        
        #if no results
        except:
            print('[*] No Results\n')
            input('Press ENTER to continue...')
            return
            

    while True:
        emailChoice = input('\nChoose an email to grab: ')
        
        if emailChoice == 'q':
            return
        
        elif not emailChoice.isnumeric():
            print('[-] Invalid input')
            continue
        
        elif int(emailChoice) > len(emailResults['value'][0]['hitsContainers'][0]['hits']) -1:
            print('[-] Invalid input')
            continue
        
        else:
            emailChoice = int(emailChoice)

        break 
    

    emailChoiceID = emailResults['value'][0]['hitsContainers'][0]['hits'][emailChoice]['_id']
    emailChoiceID = emailChoiceID.replace('/', '-')
    
    system('clear')

    #Email ID is needed for the Get Message API
    return emailChoiceID

#------------------------Get Chosen Email (Get Message API)----------------------------------------------------------

def getEmailContent(headers, emailChoiceID):

    #Get body in text form rather than HTML
    headers.update({'Prefer': 'outlook.body-content-type="text"'})
    
    #Send API Request
    emailContent = requests.get(f'https://graph.microsoft.com/v1.0/me/messages/{emailChoiceID}', headers=headers).json()
    
    #Organize Results
    emailBody = emailContent['body']['content']
    receivedTime = emailContent['receivedDateTime'].replace('T', ' ')[:-1]

    senderName = emailContent['sender']['emailAddress']['name']
    senderEmail = emailContent['sender']['emailAddress']['address']

    recipientAddresses = {}
    
    for i in range(0, len(emailContent['toRecipients'])):
        recipientAddresses.update({emailContent['toRecipients'][i]['emailAddress']['name']: emailContent['toRecipients'][i]['emailAddress']['address']})

    #Attachments
    emailAttachmentDict = {}
    if emailContent['hasAttachments']:
        emailAttachments = requests.get(f'https://graph.microsoft.com/v1.0/me/messages/{emailChoiceID}/attachments', headers=headers).json()

        for i in range(0, len(emailAttachments['value'])):
            attachmentName = emailAttachments['value'][i]['name']
            attachmentID = emailAttachments['value'][i]['id']

            emailAttachmentDict.update({attachmentName: attachmentID})

    
    #print results
    print(f'\033[4mReceived:\033[0m \n{receivedTime}\n')
    print(f'\033[4mSender:\033[0m \n{senderName} ({senderEmail})\n')
    print('\033[4mRecipients:\033[0m')
    for key, value in recipientAddresses.items():
        print(f'{key} ({value})')

    print('\n\033[4mAttachments:\033[0m')
    for key in emailAttachmentDict:
        print(key)
    
    print('\n\033[4mBody\033[0m')
    print(f'\n{emailBody}')
    input('\nPress ENTER to continue...')


    downloadChoice = ''
    if len(emailAttachmentDict) > 0:
        while True:
            downloadChoice = input('Download attachments? y/n: ')

            if downloadChoice == 'y':
                break
            if downloadChoice == 'n':
                break
            else:
                print('[-] Invalid choice')
                continue
    
    return downloadChoice, emailChoiceID, emailAttachmentDict

#------------------------Download Attachments-------------------------------------------
#GET /me/messages/{id}/attachments/{id}/$value
def downloadAttachments(headers, emailChoiceID, emailAttachmentDict):
    #output folder
    curDirectory = os.path.abspath(__file__)
    mainDirectory = os.path.dirname(os.path.dirname(curDirectory))
    outputDir = f'{mainDirectory}/output'

    for key in emailAttachmentDict:
        #print(emailAttachmentDict[key])
        getAttachment = requests.get(f'https://graph.microsoft.com/v1.0/me/messages/{emailChoiceID}/attachments/{emailAttachmentDict[key]}', headers=headers).json()
        
        if os.path.exists(outputDir):
            outputFile = open(f'{outputDir}/{key}', 'wb')
            outputFile.write(base64.b64decode(getAttachment['contentBytes']))
            outputFile.close()
            print(f"[+] {key} written to 'output/{key}'")
        else:
            os.mkdir(outputDir)
            outputFile = open(f'{outputDir}/{key}', 'wb')
            outputFile.write(base64.b64decode(getAttachment['contentBytes']))
            outputFile.close()
            print(f"[+] {key} written to 'output/{key}'")
        
        
    input('\nPress ENTER to continue...')
        

#--------------------------Main-----------------------------------------------------------
def sendQuery(user):
    
    #set auth headers for API
    headers = getHeaders(user)
    
    #query/choose email
    emailChoiceID = searchEmail(headers, user)

    if emailChoiceID == None:
        return

    #get content of chosen email
    attachmentDownloadChoice, emailChoiceID, emailAttachmentDict = getEmailContent(headers, emailChoiceID)

    if attachmentDownloadChoice == 'y':
        downloadAttachments(headers, emailChoiceID, emailAttachmentDict)
    else:
        return