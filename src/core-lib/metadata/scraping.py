import re
import requests


class Web:
    @staticmethod
    def get_objects(url, headers, time_out):
        """
        This function will extract all links in the target.
        :param url: Target (link + item in wordlist).
        :param headers: User-Agent.
        :param time_out: Time limit to wait the response of request.
        :return: Return a list of all links founded in the target (link + item in wordlist).
        """
        final_links = []
        r = requests.get(url, timeout=time_out, headers=headers)

        urls = re.findall('src=[\'"]?([^\'" >]+)', r.text)
        for item in urls:
            if item not in final_links:
                while True:
                    if str(item).startswith('\\') or str(item).startswith('/'):
                        item = str(item)[1:]
                    else:
                        break
                final_links.append(item)

        # '(?=href)href=\"(?P<href>[^\"]+)'
        # 'href=[\'"]?([^\'" >]+)'

        urls = re.findall('href=[\'"]?([^\'" >]+)', r.text)
        for item in urls:
            if item not in final_links:
                while True:
                    if str(item).startswith('\\') or str(item).startswith('/'):
                        item = str(item)[1:]
                    else:
                        break
                if 'Index of /' in r.text:
                    final_links.append(f'{url}/{item}')
                else:
                    final_links.append(item)
        return final_links
