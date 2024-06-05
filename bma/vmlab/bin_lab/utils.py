from getpass import getpass

import dateutil.parser
from defusedxml import ElementTree
import pytz
import requests

SESSION = None


def _perform_request(
    url,
    method,
    data={},
    params={},
    headers={},
    files={},
    json=True,
    dry_run=False,
    verify=True,
):
    """
    Utility method to perform an HTTP request.
    """
    if dry_run and method != "get":
        msg = "{} {} dry_run".format(url, method)
        print(msg)
        return 0

    global SESSION
    if not SESSION:
        SESSION = requests.Session()

    func = getattr(SESSION, method)

    if files:
        result = func(url, files=files, headers=headers, verify=verify)
    else:
        result = func(url, params=params, data=data, headers=headers, verify=verify)

    if result.status_code in [200, 201]:
        if json:
            return result.json()
        return result

    raise Exception(
        "{} failed requests: [{}] Response: [{}] Request data: [{}] Url: [{}] Headers: [{}]".format(
            result.status_code, result.reason, result.content, data, url, headers
        )
    )


def markdown_table_row(key, value):
    """
    Create a row in a markdown table.
    """
    return u"| {} | {} |\n".format(key, value)


def format_datetime(datestr, formatting):
    """
    Apply a dateime format to a string, according to the formatting string.
    """
    parsed_dt = dateutil.parser.parse(datestr)
    return parsed_dt.strftime(formatting)


def format_utc(datestr):
    """
    Convert dateime string to UTC format recognized by gitlab.
    """
    parsed_dt = dateutil.parser.parse(datestr)
    utc_dt = parsed_dt.astimezone(pytz.utc)
    return utc_dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def get_bugzilla_bug(bugzilla_url, bug_id):
    """
    Read bug XML, return all fields and values in a dictionary.
    """
    bug_xml = _fetch_bug_content(bugzilla_url, bug_id)
    tree = ElementTree.fromstring(bug_xml)

    bug_fields = {
        "long_desc": [],
        "attachment": [],
        "cc": [],
        "dependson": [],
        "blocked": [],
    }
    for bug in tree:
        for field in bug:
            if field.tag in ("long_desc", "attachment"):
                new = {}
                for data in field:
                    new[data.tag] = data.text
                bug_fields[field.tag].append(new)
            elif field.tag == "cc":
                bug_fields[field.tag].append(field.text)
            elif field.tag == "dependson":
                bug_fields[field.tag].append(field.text)
            elif field.tag == "blocked":
                bug_fields[field.tag].append(field.text)
            else:
                bug_fields[field.tag] = field.text

    return bug_fields


def _fetch_bug_content(url, bug_id):
    url = "{}/show_bug.cgi?ctype=xml&id={}".format(url, bug_id)
    response = _perform_request(url, "get", json=False)
    return response.content


def bugzilla_login(url, user, password):
    """
    Log in to Bugzilla as user, asking for password for a few times / untill success.
    """
    max_login_attempts = 3
    login_url = "{}/index.cgi".format(url)
    # CSRF protection bypass: GET, then POST
    _perform_request(login_url, "get", json=False)
    for attempt in range(max_login_attempts):
        if password is None:
            bugzilla_password = getpass("Bugzilla password for {}: ".format(user))
        else:
            bugzilla_password = password

        response = _perform_request(
            login_url,
            "post",
            headers={"Referer": login_url},
            data={
                "Bugzilla_login": user,
                "Bugzilla_password": bugzilla_password,
            },
            json=False,
        )
        if response.cookies:
            break
        print("Failed to log in (attempt {})".format(attempt + 1))
    else:
        raise Exception("Failed to log in after {} attempts".format(max_login_attempts))


def validate_list(integer_list):
    """
    Ensure that the user-supplied input is a list of integers, or a list of strings
    that can be parsed as integers.
    """
    if not integer_list:
        raise Exception("No bugs to migrate! Call `migrate` with a list of bug ids.")

    if not isinstance(integer_list, list):
        raise Exception(
            "Expected a list of integers. Instead recieved "
            "a(n) {}".format(type(integer_list))
        )

    for i in integer_list:
        try:
            int(i)
        except ValueError:
            raise Exception(
                "{} is not able to be parsed as an integer, "
                "and is therefore an invalid bug id.".format(i)
            ) from ValueError
