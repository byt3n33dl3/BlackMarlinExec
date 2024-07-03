import requests
import json
from os import system
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary


#------------Here is where you create a template email--------------------------
def templateEmail():

    recipient = input('To: ')
        
    data={
            "message": {

                #Enter subject (str)
                #"subject": '[subject]',
                "subject": 'Test Template Email',
                "body": {
                "contentType": "Text",

                #Enter Body (str)
                #"content": '[body]'
                "content": 'Test of the template email.'
                },
                "toRecipients": [
                {
                    "emailAddress": {
                    #Enter Recipient (str)
                    #"address": '[recipient]'
                    "address": recipient
                    }
                }
                ],
        
            },
            "saveToSentItems": "false"
            }
            
    return data

#---------------------------------Create New Email-----------------------------------------------
def createEmail():

    data=''
    #email components
    while True:
        system('clear')
        recipient = input('To Address: ')
        if recipient == 'q':
            break

        subject = input('Subject: ')
        if subject == 'q':
            break

        body = input('Body: ')
        if body == 'q':
            break

        system('clear')

        print('Confirmation:\n')
        print(f'To: {recipient}')
        print(f'Subject: {subject}')
        print(f'Body: {body}')

        response = input('\nIs everything correct? y/n/q: ')

        if response == 'y':

            data={
            "message": {
                "subject": subject,
                "body": {
                "contentType": "Text",
                "content": body
                },
                "toRecipients": [
                {
                    "emailAddress": {
                    "address": recipient
                    }
                }
                ],
        
            },
            "saveToSentItems": "false"
            }
            
            break
            
            

        elif response == 'n':
            system('clear')
            continue

        elif response == 'q':
            system('clear')
            break
    
    return data
#-----------------Main------------------------------------
def sendQuery(user):
    data=''
    system('clear')

    while True:
        isCustom = input('New or template email? n/t: ')
        
        if isCustom == 'n':
            data = createEmail()
            break

        elif isCustom == 'q':
            return
        
        elif isCustom == 't':
            data = templateEmail()
            while True:
                
                sendTemplateEmail = input('Confirm send? y/n: ')

                if sendTemplateEmail == 'y':
                    break
                if sendTemplateEmail == 'n':
                    data == None
                    return data
                elif sendTemplateEmail != 'y' or sendTemplateEmail != 'n':
                    print('[-] Invalid input\n')
                    continue
            break

        else:
            print('[-] Invalid input')
            continue
    
    if data == None:
        return
    
    else:

        #get user and token
        tokenLibrary = openTokenLibrary()

        #make and send query
        headers={'Authorization': 'Bearer ' + tokenLibrary[user]['access_token'], 'Content-type': 'application/json'}

        #send API request to send email
        graph_data = requests.post('https://graph.microsoft.com/v1.0/me/sendMail', json=data, headers=headers)

        if str(graph_data) == '<Response [202]>':
            print('[+] Email Sent Successfully\n')
            
        else:
            print(graph_data.text)
        
        input('Press ENTER to continue...')