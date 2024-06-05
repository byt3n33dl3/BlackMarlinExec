from collections import namedtuple
import os

import yaml

from .utils import _perform_request

Config = namedtuple(
    "Config",
    [
        "gitlab_base_url",
        "gitlab_project_id",
        "bugzilla_base_url",
        "bugzilla_user",
        "bugzilla_password",
        "bugzilla_auto_reporter",
        "bugzilla_closed_states",
        "default_headers",
        "component_mappings",
        "bugzilla_users",
        "gitlab_users",
        "gitlab_misc_user",
        "default_gitlab_labels",
        "datetime_format_string",
        "map_operating_system",
        "map_keywords",
        "keywords_to_skip",
        "map_milestones",
        "milestones_to_skip",
        "gitlab_milestones",
        "dry_run",
        "include_bugzilla_link",
        "use_bugzilla_id",
        "verify",
    ],
)


def get_config(path):
    configuration = {}
    configuration.update(_load_defaults(path))
    configuration.update(
        _load_user_id_cache(
            path,
            configuration["gitlab_base_url"],
            configuration["default_headers"],
            configuration["verify"],
        )
    )
    if configuration["map_milestones"]:
        configuration.update(
            _load_milestone_id_cache(
                configuration["gitlab_project_id"],
                configuration["gitlab_base_url"],
                configuration["default_headers"],
                configuration["verify"],
            )
        )
    configuration.update(_load_component_mappings(path))
    return Config(**configuration)


def _load_defaults(path):
    with open(os.path.join(path, "defaults.yml")) as f:
        config = yaml.safe_load(f)

    defaults = {}

    for key in config:
        if key == "gitlab_private_token":
            defaults["default_headers"] = {"private-token": config[key]}
        else:
            defaults[key] = config[key]

    return defaults


def _load_user_id_cache(path, gitlab_url, gitlab_headers, verify):
    """
    Load cache of GitLab usernames and ids
    """
    print("Loading user cache...")
    with open(os.path.join(path, "user_mappings.yml")) as f:
        bugzilla_mapping = yaml.safe_load(f)

    gitlab_users = {}
    for user in bugzilla_mapping:
        gitlab_username = bugzilla_mapping[user]
        uid = _get_user_id(gitlab_username, gitlab_url, gitlab_headers, verify=verify)
        gitlab_users[gitlab_username] = str(uid)

    mappings = {}
    # bugzilla_username: gitlab_username
    mappings["bugzilla_users"] = bugzilla_mapping

    # gitlab_username: gitlab_userid
    mappings["gitlab_users"] = gitlab_users

    return mappings


def _load_milestone_id_cache(project_id, gitlab_url, gitlab_headers, verify):
    """
    Load cache of GitLab milestones and ids
    """
    print("Loading milestone cache...")

    gitlab_milestones = {}
    url = "{}/projects/{}/milestones".format(gitlab_url, project_id)
    result = _perform_request(url, "get", headers=gitlab_headers, verify=verify)
    if result and isinstance(result, list):
        for milestone in result:
            gitlab_milestones[milestone["title"]] = milestone["id"]

    return {"gitlab_milestones": gitlab_milestones}


def _get_user_id(username, gitlab_url, headers, verify):
    url = "{}/users?username={}".format(gitlab_url, username)
    result = _perform_request(url, "get", headers=headers, verify=verify)
    if result and isinstance(result, list):
        return result[0]["id"]
    raise Exception("No gitlab account found for user {}".format(username))


def _load_component_mappings(path):
    with open(os.path.join(path, "component_mappings.yml")) as f:
        component_mappings = yaml.safe_load(f)

    return {"component_mappings": component_mappings}
