import requests

# SCIP and integer group variables
GITLAB_GROUP_ID = 7
GITLAB_PROJECT_ID = 57
TESTGL_GROUP_ID = 4
TESTGL_PROJECT_ID = 2

class Gitlab(object):
    def __init__(self, url, token)
        self.base = url
        self.headers = {"private-token": token}

    def get_user(self, username):
        url = "{}{}?{}={}".format(self.base, "users", "username", username)
        result = _perform_request(url, "get", headers=self.headers)
        if result and isinstance(result, list):
            return result[0]
        else:
            None

    def get_users_from_group(self, group):
        url = "{}{}/{}/{}".format(self.base, "groups", group, "members")
        return _perform_request(url, "get", headers=self.headers)

    def get_users_from_project(self, project):
        url = "{}{}/{}/{}".format(self.base, "projects", project, "members")
        return _perform_request(url, "get", headers=self.headers)

    def get_my_groups(self):
        url = "{}{}".format(self.base, "groups")
        return _perform_request(url, "get", headers=self.headers)

    def create_user(self, user):
        print u"Creating {} in test gitlab".format(user["name"])
        user_data = {
            "email": "cm.alephone+git{}@gmail.com".format(user["username"]),
            "username": user["username"],
            "name": user["name"],
            "password": "{} fish {} yaks".format(user["username"], user["username"]),
            "confirm": False,
        }
        url = "{}{}".format(self.base, "users")
        new_user = _perform_request(url, "post", params=user_data, headers=self.headers, json=True)
        return new_user

    def add_user_to_group(self, group, user, access_level=30):
        user_to_group = {
            "user_id": user["id"],
            "access_level": access_level,
        }
        url = "{}{}/{}/{}".format(self.base, "groups", group, "members")
        add_user = _perform_request(url, "post", params=user_to_group, headers=self.headers, json=True)
        print u"Added {} to group integer".format(user["username"])

        return add_user

    def add_user_to_project(self, project, user, access_level=30):
        user_to_project = {
            "user_id": user["id"],
            "access_level": access_level,
        }
        url = "{}{}/{}/{}".format(self.base, "projects", project, "members")
        add_user = _perform_request(url, "post", params=user_to_project, headers=self.headers, paginated=False)
        print u"Added {} to project SCIP".format(user["username"])

        return add_user

    def create_users_in_group(self, group, users):
        for user in users:
            current_user = self.get_user(user["username"])
            if not current_user:
                current_user = self.create_user(user)
                if "id" not in current_user:
                    print "error"
                    return
                print "Created {} with id {}".format(current_user["username"], current_user["id"])

            result = self.add_user_to_group(group, current_user, access_level=user["access_level"])
            if "id" not in result:
                print "error"
                return

    def create_users_in_project(self, project, users):
        for user in users:
            current_user = self.get_user(user["username"])
            if not current_user:
                current_user = self.create_user(user)
                if "id" not in current_user:
                    print "error"
                    return
                print "Created {} with id {}".format(current_user["username"], current_user["id"])

            result = self.add_user_to_project(project, current_user, access_level=user["access_level"])
            if "id" not in result:
                print "error"
                return


def _perform_request(url, method, params={}, headers={}, paginated=True):
    '''
    Perform an HTTP request.
    '''
    func = getattr(requests, method)

    # perform paginated requests
    params.update({"per_page": 100})
    result = func(url, params=params, headers=headers)

    if not paginated:
        if result.status_code in [200, 201]:
            return result.json()
        else:
            raise Exception("Failed request {}".format(result.status_code))

    # paginated request
    final_results = []
    final_results.extend(result.json())
    while "link" in result.headers:
        url_parts = result.headers["link"].split()
        if url_parts[1] != 'rel="next",':
            break
        else:
            next_url = url_parts[0].strip("<").rstrip(">;")
            result = func(next_url, headers=headers)
            final_results.extend(result.json())

    return final_results

def migrate_users_from_group(client_from, client_to):
    # integer group
    users = client_from.get_users_from_group(GITLAB_GROUP_ID)
    client_to.create_users_in_group(TESTGL_GROUP_ID, users)

def migrate_users_from_project(client_from, client_to):
    # scip project
    users = client_from.get_users_from_project(GITLAB_PROJECT_ID)
    client_to.create_users_in_project(TESTGL_PROJECT_ID, users)


def main():
    from_private_token = "XXX"
    from_url = "https://git.test.com/api/v3/"
    to_private_token = "YYY"
    to_url = "http://git.example.com/api/v3/"

    # clients
    client_from = Gitlab(from_url, from_private_token)
    client_to = Gitlab(to_url, to_private_token)

    migrate_users_from_project(client_from, client_to)

if __name__ == "__main__":
    main()
