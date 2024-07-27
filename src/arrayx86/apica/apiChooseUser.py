import pickle
from src.bme import Barracuda

def pickUser():
    
    #open token library
    tokenLibrary = openTokenLibrary()

    #list available tokens to user
    print('\033[4mAvailable Users:\033[0m')

    #create list from token library users
    userList = ['']
    for user in tokenLibrary:
        userList.append(user)

    #print list to user
    for i in range(1, len(userList)):
        print(f'{i}) {userList[i]}')

    #choose user for query
    userChoice = int(input('\nChoose a user: '))
    userChoice = userList[userChoice]
    
    return userChoice

def openTokenLibrary():
    pickleIn = open('tokenLibrary.pickle', 'rb')
    tokenLibrary = pickle.load(pickleIn)
    pickleIn.close()
    return tokenLibrary

if __name__=='__main__':
    pickUser()