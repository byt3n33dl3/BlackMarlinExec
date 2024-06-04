#!/usr/bin/env python

import requests
import os
import sys
import argparse
import dsstore

requests.packages.urllib3.disable_warnings()

RED = '\x1b[91m'
GREEN = '\033[32m'
END = '\033[0m'

def getArgs():
    parser = argparse.ArgumentParser(description="ds_store enumerator",epilog="Something cool.")
    parser.add_argument('-u','--url',type=str,help='Target index URL',required=True)

    args = parser.parse_args()
    url = args.url
    return url


#First check for .ds_store file
def firstCheck(url):
    s = requests.get(url + "/.DS_Store", verify=False)
    if s.status_code == 200:
        print(GREEN + "[!] .ds_store file is present on the webserver." + END)
        ds_index = s.url
        print(GREEN + "[+] Enumerating directories based on .ds_server file:" + END)
        print("----------------------------")
        return ds_index

    else:
        print(RED + "[X] .ds_store file not found in base directory." + END)
        sys.exit(0)


#Save index ds_store file
def saveIndexDS():
    index_ds = requests.get(url + "/.DS_Store", allow_redirects=True, verify=False)
    index_file = open('ds_store_index','wb').write(index_ds.content)
    index = 'ds_store_index'
    return index

#Read the .ds_store files
def readDS_store(ds,url):
    with open(ds,'rb') as f:
        d = dsstore.DS_Store(f.read(), debug=False)
        files = d.traverse_root()
        file_list = []
        for f in files:
            file_list.append(f)
        final_list = []
        for dir in file_list:
            if dir not in final_list:
                final_list.append(dir)
        for item in final_list:
            print("[!] " + url + "/" + item)
        print("----------------------------")
        return final_list

#Recursive function to traverse through all directories
def recurseDS(site_map,url):
    dsfile = "/.DS_Store"
    for item in site_map:
        new_url = url + "/" + item
        next_ds = requests.get(new_url + dsfile, allow_redirects=True, verify=False)
        if next_ds.status_code == 401 or next_ds.status_code == 404:
            pass
        else:
            new_ds = open('tmp_ds','wb').write(next_ds.content)
            ds_file = 'tmp_ds'
            mapping = readDS_store(ds_file,new_url)
            recurseDS(mapping,new_url)


if __name__=="__main__":
    try:
	    url = getArgs()
	    ds_index = firstCheck(url)
	    ds_file = saveIndexDS()
	    site_map = readDS_store(ds_file,url)
	    recurseDS(site_map,url)
	    print(GREEN + "[*] Finished traversing. No remaining .ds_store files present." + END)
	    print(GREEN + "[*] Cleaning up .ds_store files saved to disk." + END)
	    os.remove('tmp_ds')
	    os.remove('ds_store_index')
	    sys.exit(0)
    except:
	    pass
