import requests
import json
import pickle
import os
from os import system
import app_config
from apiCalls.apiChooseUser import pickUser
from apiCalls.apiChooseUser import openTokenLibrary


def sendQuery(user):

    #change this to your site
    website = 'http://localhost:5000'
    tokenLibrary = openTokenLibrary()

    scopeList = app_config.SCOPE
    scopeHeader = ''

    for scope in scopeList:
        scope = f'https://graph.microsoft.com/{scope} '
        scopeHeader += scope
        
    redirectUrlHeader = f'{website}{app_config.REDIRECT_PATH}'

    headers = {'grant_type': 'refresh_token', 'refresh_token': tokenLibrary[user]['refreshToken'], 'client_id': app_config.CLIENT_ID, 'client_secret': app_config.CLIENT_SECRET, 'scope': scopeHeader, 'redirect_uri': redirectUrlHeader, 'Content-Type': 'application/x-www-form-urlencoded'}

    refreshTokenAPI = requests.post('https://login.microsoftonline.com/common/oauth2/v2.0/token',  data=headers).json()

    #----------------Update Dictionary -----------------------
    refreshToken = tokenLibrary[user]['refreshToken']
    newAccessToken = refreshTokenAPI['access_token']
    
    del tokenLibrary[user]

    #update existing library to save other users
    newLibraryEntry = {user: {'access_token': newAccessToken, 'refreshToken': refreshToken}}
    tokenLibrary.update(newLibraryEntry)

    #delete old file
    os.remove('tokenLibrary.pickle')

    pickleOut = open('tokenLibrary.pickle', 'wb')
    pickle.dump(tokenLibrary, pickleOut)
    pickleOut.close()

    print(f'[+] Token Updated for {user}\n')

    input('Press ENTER to continue...')
    system('clear')