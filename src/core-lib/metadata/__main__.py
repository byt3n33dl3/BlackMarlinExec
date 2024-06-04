#!/usr/bin/env python3

import os
import sys
import datetime
import subprocess
import time
import requests
from goblyn.core.scraping import Web
from goblyn.db.extensions.all_file_extensions import afe
from goblyn.core.banners import *


def main():
    # Verifies if the user has input more than one arguments or has used "-help" argument.
    if len(sys.argv) <= 1 or sys.argv[1] == '-help':
        banner_2()
        exit(1)

    # Variables of arguments.
    init_time = (datetime.datetime.now())
    target, ftypes, word_list, output_file,\
        user_agent, delay, time_out = None, None, None, None, None, None, None

    # Passing arguments to variables.
    for item in sys.argv:
        try:
            if item == '-t' or item == '--target':
                target = sys.argv[sys.argv.index(item) + 1]

            if item == '-wl' or item == '--word-list':
                word_list = sys.argv[sys.argv.index(item) + 1]

            if '--file-types=' in item:
                ftypes = sys.argv[sys.argv.index(item)]
                ftypes = ftypes.replace('--file-types=', '')

                if str(ftypes).lower() != 'all':
                    ftypes = ftypes.split(',')

            if item == '-o' or item == '--output':
                output_file = sys.argv[sys.argv.index(item) + 1]

            if '--user-agent=' in item:
                user_agent = sys.argv[sys.argv.index(item)]
                user_agent = user_agent.replace('--user-agent=', '').replace('"', '').replace("'", '')

            if item == '-d' or item == '--delay':
                delay = sys.argv[sys.argv.index(item) + 1]

            if '--time-out=' in item:
                time_out = sys.argv[sys.argv.index(item)]
                time_out = time_out.replace('--time-out=', '')

        except IndexError:
            # If some error happen will return the help banner.
            banner_2()
            exit(1)

    # After pass the arguments to variables will check for errors of syntax.
    if not target:
        banner_4(
            'Please, select a target.')
        exit(1)
    else:
        if not'://' in str(target) or str(target)[-1:] != '/':
            banner_4(
                'Example of target: "-t https://www.google.com/" or "-t http://192.168.15.23/"')
            exit(1)

    if not ftypes:
        banner_4(
            'Please, select the file types. If you want to use all file types you need to use "--file-types=ALL".')
        exit(1)

    try:
        with open(word_list, 'r') as file:
            file.close()
    except FileNotFoundError:
        banner_4("Wordlist not found! Please, try to use full path of Wordlist.")
        exit(1)

    if output_file:
        with open(output_file, 'w') as op_file:
            op_file.close()

    try:
        if delay:
            delay = int(delay)
        else:
            delay = 0.1
    except TypeError:
        banner_4("Invalid delay time.")
        exit(1)

    try:
        if time_out:
            time_out = int(time_out)
    except (AttributeError, ValueError):
        banner_4("Invalid time out value.")
        exit(1)

    def clear_line():
        """
        Function for clear last line in STDOUT.
        """
        print("\033[A                             \033[A")
        # sys.stdout.write("\033[F")  # Back to previous line.
        # sys.stdout.write("\033[K")  # Clear line.

    # Shows the initial banner.
    banner_0()
    # Shows the banner of target.
    banner_1(target, init_time, str(ftypes).replace('[', '').replace(']', '').replace("'", ''))

    # Some variables.
    tmp_path = (os.path.dirname(os.path.abspath(__file__))).replace('\\', '/')
    tmp_path += '/tmp/'
    start = False
    circle = 0

    if not user_agent:
        user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)' \
                     ' Chrome/92.0.4515.159 Safari/537.36 '  # 'Goblyn 0.1'

    headers = {
        'Refer': 'https://www.google.com/',
        'User-Agent': f'{user_agent}'
    }

    # Start of scan.
    try:
        # Opening wordlist.
        with open(word_list, 'r') as wl:
            # Item = line in the wordlist
            for item in wl.read().split('\n'):
                target_url = f'{target}{item}'  # Adds the item of wordlist to url.
                # Start is a variable to help the printing. Not so important.
                if not start:
                    start = True
                    # The circle variable will help with the print animation of [-][/][|][\].
                    if circle == 0:
                        print(f'  {Colors.red}[{Colors.end_color}-{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 1:
                        print(rf'  {Colors.red}[{Colors.end_color}\{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 2:
                        print(rf'  {Colors.red}[{Colors.end_color}|{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 3:
                        print(rf'  {Colors.red}[{Colors.end_color}/{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle = 0

                else:
                    clear_line()
                    if circle == 0:
                        print(f'  {Colors.red}[{Colors.end_color}-{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 1:
                        print(rf'  {Colors.red}[{Colors.end_color}\{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 2:
                        print(rf'  {Colors.red}[{Colors.end_color}|{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle += 1

                    elif circle == 3:
                        print(rf'  {Colors.red}[{Colors.end_color}/{Colors.red}]{Colors.end_color} '
                              f'{Colors.violet}Testing:{Colors.end_color} {target_url}')
                        circle = 0
                # Now will verify if the link (target + item of wordlist) is avaliable.
                try:
                    r = requests.get(target_url, timeout=2, headers=headers)

                    if r.status_code == 200:
                        clear_line()
                        print(f'  {Colors.red}[{Colors.end_color}-{Colors.red}]{Colors.end_color} '
                              f'{Colors.purple}Finded:{Colors.end_color} {target_url}\n')
                        links = Web.get_objects(target_url, time_out=time_out, headers=headers)

                        # If link is available will extract all urls in this link.
                        for link in links:
                            time.sleep(delay)
                            # Links = all links founded in the url.
                            if str(link) != '':  # Removing NULL values.

                                if str(ftypes).lower() == 'all':  # If user has set ALL file types Goblyn will use
                                    ftypes = afe                  # list of all file types. "afe" is a dict.

                                for ft in ftypes:   # ftypes will keep with the file types, example "ftypes='DOCX,PDF'".
                                    # Now verifys if the link (target + item of wordlist) ends with the files types.
                                    if str(link).endswith(f'.{str(ft).lower()}'):

                                        if '://' in str(link):  # If the link are complete (with :// and /).
                                            print(f'  {Colors.red}[{Colors.end_color}*{Colors.red}]'
                                                  f'{Colors.end_color} '
                                                  f'{Colors.blue}{link}{Colors.end_color}\n')
                                            name = str(link).split('/')
                                            # Will verify if the content in link (target + item of wordlist) is
                                            # avaliable.
                                            try:
                                                response = requests.get(link, timeout=2, headers=headers)

                                            except Exception as error:
                                                print(f'  {Colors.red}[{Colors.end_color}!{Colors.red}]'
                                                      f'{Colors.end_color} '
                                                      f'{Colors.red}{error}{Colors.end_color}\n\n')
                                                continue
                                            # Will try to download the content in link (target + item of wordlist).
                                            try:
                                                with open(rf'{tmp_path}/{name[-1]}', 'wb') as file:
                                                    file.write(response.content)
                                                    file.close()
                                                # Using exiftool.
                                                output = subprocess.getoutput(
                                                    f'exiftool {tmp_path}{name[-1]}')
                                                # Removing file.
                                                os.remove(f'{tmp_path}/{name[-1]}')
                                            except Exception as error:
                                                output = (f'{Colors.red}[{Colors.end_color}!{Colors.red}]'
                                                          f'{Colors.end_color} '
                                                          f'{Colors.red}{error}{Colors.end_color}\n\n')
                                            # Printing the metadatas in the STDOUT.
                                            for line in str(output).split('\n'):
                                                print(f'  {line}')
                                            # If the user has use -o to save the output in a file the Goblyn will
                                            # save the content of metadata in the file.
                                            if output_file:
                                                with open(output_file, 'a') as op_file:
                                                    op_file.write(link)
                                                    op_file.write('\n\n')
                                                    op_file.write(output)
                                                    op_file.write('\n\n')
                                                    op_file.close()

                                            print('\n')

                                        else:
                                            # This "else" is if the link is without :// and / in the end.
                                            total_path = f'{target}{link}'  # Creating link (target + item of wordlist).
                                            name = str(link).split('/')

                                            p_start = total_path.find('//') + 2
                                            p_end = total_path.find('/', p_start)
                                            schema = target.split('://')[0]
                                            new_url = f'{schema}://{total_path[p_start:p_end]}/{link}'

                                            print(f'  {Colors.red}[{Colors.end_color}*{Colors.red}]'
                                                  f'{Colors.end_color} '
                                                  f'{Colors.blue}{new_url}{Colors.end_color}\n')
                                            # Will verify if the content in link (target + item of wordlist) is
                                            # avaliable.
                                            try:
                                                response = requests.get(new_url, timeout=2
                                                                        , headers=headers)

                                            except Exception as error:
                                                print(f'{Colors.red}[{Colors.end_color}!{Colors.red}]'
                                                      f'{Colors.end_color} '
                                                      f'{Colors.red}{error}{Colors.end_color}')
                                                continue
                                            # Will try to download the content in link (target + item of wordlist).
                                            try:
                                                with open(f'{tmp_path}/{name[-1]}', 'wb') as file:
                                                    file.write(response.content)
                                                    file.close()
                                                # Using exiftool.
                                                output = subprocess.getoutput(
                                                    f'exiftool {tmp_path}/{name[-1]}')
                                                # Removing file.
                                                os.remove(f'{tmp_path}/{name[-1]}')
                                            except Exception as error:
                                                output = (f'{Colors.red}[{Colors.end_color}!{Colors.red}]'
                                                            f'{Colors.end_color} '
                                                            f'{Colors.red}{error}{Colors.end_color}')
                                            # Printing the metadatas in the STDOUT.
                                            for line in str(output).split('\n'):
                                                print(f'  {line}')
                                            # If the user has use -o to save the output in a file the Goblyn will
                                            # save the content of metadata in the file.
                                            if output_file:
                                                with open(output_file, 'a') as op_file:
                                                    op_file.write(total_path)
                                                    op_file.write('\n\n')
                                                    op_file.write(output)
                                                    op_file.write('\n\n')
                                                    op_file.close()

                                            print('\n')

                except Exception as error:
                    if error:
                        pass

    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == '__main__':
    main()
