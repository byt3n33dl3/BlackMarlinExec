import requests
import json
from os import system
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary


#-----------Auth Headers------------------------------
def getHeaders(user):
    tokenLibrary = openTokenLibrary()
    headers={'Authorization': 'Bearer ' + tokenLibrary[user]['bme_access_token'], 'Content-type': 'application/json'}
    return headers

#----------List Rules -------------------------------
def listInboxRules(headers):

    inboxRules = requests.get('https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules', headers=headers).json()

    inboxRuleDict = {}
    deleteChoice = ''

    if len(inboxRules['value']) > 0:
        for i in range(0, len(inboxRules['value'])):
            print(f"{i}) \033[4m{inboxRules['value'][i]['displayName']}\033[0m  \n\n \
            Conditions: \n \
            if:\n \
                {inboxRules['value'][i]['conditions']}\n \
            then: \n \
                {inboxRules['value'][i]['actions']}\n\n")
        
            #gather IDs for rules
            inboxRuleDict.update({i: inboxRules['value'][i]['id']})

        input('Press ENTER to continue...')
        
        
        while True:
            deleteChoice = input('Would you like to delete a rule? y/n: ')
            if deleteChoice =='n':
                break
            
            elif deleteChoice == 'y':
                deleteChoice = int(input('Which rule?: '))
                break
            else:
                print('[-] Invalid input')
                continue
                

    else:
        print('[-] No inbox rules for user\n')
        input('Press ENTER to continue...')

    system('clear')

    return deleteChoice, inboxRuleDict

#----------Delete Rule -------------------------------

def deleteRule(headers, ruleID):

    deleteInboxRule = requests.delete(f'https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules/{ruleID}', headers=headers)

    if str(deleteInboxRule) == '<Response [204]>':
        print('[+] Rule deleted successfully\n')
    
    else:
        print('[-] Error\n')
        print(deleteInboxRule)
        
    input('Press ENTER to continue...')
    system('clear')

#------------Main---------------------------------------   
def sendQuery(user):
    
    #set auth headers for API
    headers = getHeaders(user)

    #send API to create rule
    deleteChoice, inboxRuleDict = listInboxRules(headers)

    #if delete chosen
    if isinstance(deleteChoice, int):
        ruleID = inboxRuleDict[deleteChoice]
        deleteRule(headers, ruleID)