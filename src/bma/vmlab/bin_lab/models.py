import re

from .utils import _perform_request, format_datetime, format_utc, markdown_table_row

CONF = None


class IssueThread:
    """
    Everything related to an issue in GitLab, e.g. the issue itself and subsequent comments.
    """

    def __init__(self, config, fields):
        global CONF
        CONF = config
        self.load_objects(fields)

    def load_objects(self, fields):
        """
        Load the issue object and the comment objects.
        If CONF.dry_run=False, then Attachments are created in GitLab in this step.
        """
        self.issue = Issue(fields)
        self.comments = []
        """
        fields["long_desc"] gets peared down in Issue creation (above). This is because bugzilla
        lacks the concept of an issue description, so the first comment is harvested for
        the issue description, as well as any subsequent comments that are simply attachments
        from the original reporter. What remains below should be a list of genuine comments.
        """

        for comment_fields in fields["long_desc"]:
            if comment_fields.get("thetext"):
                self.comments.append(Comment(comment_fields))

    def save(self):
        """
        Save the issue and all of the comments to GitLab.
        If CONF.dry_run=True, then only the HTTP request that would be made is printed.
        """
        self.issue.save()

        for comment in self.comments:
            comment.issue_id = self.issue.id
            comment.save()

        # close the issue in GitLab, if it is resolved in Bugzilla
        if self.issue.status in CONF.bugzilla_closed_states:
            self.issue.close()


class Issue:
    """
    The issue model
    """

    required_fields = ["sudo", "title", "description"]
    data_fields = [
        "sudo",
        "created_at",
        "title",
        "description",
        "assignee_ids",
        "milestone_id",
        "labels",
    ]

    def __init__(self, bugzilla_fields):
        self.headers = CONF.default_headers
        validate_user(bugzilla_fields["reporter"])
        validate_user(bugzilla_fields["assigned_to"])
        self.load_fields(bugzilla_fields)

    def load_fields(self, fields):
        self.title = fields["short_desc"]
        self.sudo = CONF.gitlab_users[CONF.bugzilla_users[fields["reporter"]]]
        self.assignee_ids = [
            CONF.gitlab_users[CONF.bugzilla_users[fields["assigned_to"]]]
        ]
        self.created_at = format_utc(fields["creation_ts"])
        self.status = fields["bug_status"]
        self.create_labels(
            fields["component"], fields.get("op_sys"), fields.get("keywords")
        )
        self.bug_id = fields["bug_id"]
        milestone = fields["target_milestone"]
        if CONF.map_milestones and milestone not in CONF.milestones_to_skip:
            self.create_milestone(milestone)
        self.create_description(fields)

    def create_labels(self, component, operating_system, keywords):
        """
        Creates 4 types of labels: default labels listed in the configuration, component labels,
        operating system labels, and keyword labels.
        """
        labels = []
        if CONF.default_gitlab_labels:
            labels.extend(CONF.default_gitlab_labels)

        component_label = CONF.component_mappings.get(component)
        if component_label:
            labels.append(component_label)

        # Do not create a label if the OS is other. That is a meaningless label.
        if (
            CONF.map_operating_system
            and operating_system
            and operating_system != "Other"
        ):
            labels.append(operating_system)

        if CONF.map_keywords and keywords:
            # Input: payload of XML element like this: <keywords>SECURITY, SUPPORT</keywords>
            # Bugzilla restriction: You may not use commas or whitespace in a keyword name.
            for k in keywords.replace(" ", "").split(","):
                if not (CONF.keywords_to_skip and k in CONF.keywords_to_skip):
                    labels.append(k)

        self.labels = ",".join(labels)

    def create_milestone(self, milestone):
        """
        Looks up milestone id given its title or creates a new one.
        """
        if milestone not in CONF.gitlab_milestones:
            print("Create milestone: {}".format(milestone))
            url = "{}/projects/{}/milestones".format(
                CONF.gitlab_base_url, CONF.gitlab_project_id
            )
            response = _perform_request(
                url,
                "post",
                headers=self.headers,
                data={"title": milestone},
                verify=CONF.verify,
            )
            CONF.gitlab_milestones[milestone] = response["id"]

        self.milestone_id = CONF.gitlab_milestones[milestone]

    def create_description(self, fields):
        """
        An opinionated description body creator.
        """
        ext_description = ""

        # markdown table header
        self.description = markdown_table_row("", "")
        self.description += markdown_table_row("---", "---")

        if CONF.include_bugzilla_link:
            bug_id = fields["bug_id"]
            link = "{}/show_bug.cgi?id={}".format(CONF.bugzilla_base_url, bug_id)
            self.description += markdown_table_row(
                "Bugzilla Link", "[{}]({})".format(bug_id, link)
            )

        formatted_dt = format_datetime(
            fields["creation_ts"], CONF.datetime_format_string
        )
        self.description += markdown_table_row("Created on", formatted_dt)

        if fields.get("resolution"):
            self.description += markdown_table_row("Resolution", fields["resolution"])
            self.description += markdown_table_row(
                "Resolved on",
                format_datetime(fields["delta_ts"], CONF.datetime_format_string),
            )

        self.description += markdown_table_row("Version", fields.get("version"))
        self.description += markdown_table_row("OS", fields.get("op_sys"))
        self.description += markdown_table_row(
            "Architecture", fields.get("rep_platform")
        )

        deplist = ""
        blocklist = ""
        if fields.get("dependson"):
            for depends in fields.get("dependson"):
                deplist += "[{}]({}) ".format(depends, link)
            self.description += markdown_table_row("Depends On", deplist)
        if fields.get("blocked"):
            for blocked in fields.get("blocked"):
                blocklist += "[{}]({}) ".format(blocked, link)
            self.description += markdown_table_row("Blocked by", blocklist)

        # add first comment to the issue description
        attachments = []
        to_delete = []
        comment0 = fields["long_desc"][0]
        if fields["reporter"] == comment0["who"] and comment0["thetext"]:
            ext_description += "\n## Extended Description \n"
            ext_description += "\n\n".join(re.split("\n+", comment0["thetext"]))
            self.update_attachments(fields["reporter"], comment0, attachments)
            del fields["long_desc"][0]

        for i in range(0, len(fields["long_desc"])):
            comment = fields["long_desc"][i]
            if self.update_attachments(fields["reporter"], comment, attachments):
                to_delete.append(i)

        # delete comments that have already added to the issue description
        for i in reversed(to_delete):
            del fields["long_desc"][i]

        if attachments:
            self.description += markdown_table_row(
                "Attachments", ", ".join(attachments)
            )

        if ext_description:
            # for situations where the reporter is a generic or old user, specify the original
            # reporter in the description body
            if fields["reporter"] == CONF.bugzilla_auto_reporter:
                # try to get reporter email from the body
                _, part, user_data = ext_description.rpartition("Submitter was ")
                # partition found matching string
                if part:
                    regex = r"^(\S*)\s?.*$"
                    email = re.match(regex, user_data, flags=re.M).group(1)
                    self.description += markdown_table_row("Reporter", email)
            # Add original reporter to the markdown table
            elif CONF.bugzilla_users[fields["reporter"]] == CONF.gitlab_misc_user:
                self.description += markdown_table_row("Reporter", fields["reporter"])

            self.description += ext_description

    def update_attachments(self, reporter, comment, attachments):
        """
        Fetches attachments from comment if authored by reporter.
        """
        if comment.get("attachid") and comment.get("who") == reporter:
            filename = Attachment.parse_file_description(comment.get("thetext"))
            attachment_markdown = Attachment(comment.get("attachid"), filename).save()
            attachments.append(attachment_markdown)
            return True
        return False

    def validate(self):
        for field in self.required_fields:
            value = getattr(self, field)
            if not value:
                raise Exception("Missing value for required field: {}".format(field))
        return True

    def save(self):
        self.validate()
        url = "{}/projects/{}/issues".format(
            CONF.gitlab_base_url, CONF.gitlab_project_id
        )
        data = {k: v for k, v in self.__dict__.items() if k in self.data_fields}

        if CONF.use_bugzilla_id is True:
            print("Using original issue id")
            data["iid"] = self.bug_id

        self.headers["sudo"] = self.sudo

        response = _perform_request(
            url,
            "post",
            headers=self.headers,
            data=data,
            json=True,
            dry_run=CONF.dry_run,
            verify=CONF.verify,
        )

        if CONF.dry_run:
            # assign a random number so that program can continue
            self.id = 5
            return

        self.id = response["iid"]
        print("Created issue with id: {}".format(self.id))

    def close(self):
        url = "{}/projects/{}/issues/{}".format(
            CONF.gitlab_base_url, CONF.gitlab_project_id, self.id
        )
        data = {
            "state_event": "close",
        }
        self.headers["sudo"] = self.sudo

        _perform_request(
            url,
            "put",
            headers=self.headers,
            data=data,
            dry_run=CONF.dry_run,
            verify=CONF.verify,
        )


class Comment:
    """
    The comment model
    """

    required_fields = ["sudo", "body", "issue_id"]
    data_fields = ["created_at", "body"]

    def __init__(self, bugzilla_fields):
        self.headers = CONF.default_headers
        validate_user(bugzilla_fields["who"])
        self.load_fields(bugzilla_fields)

    def load_fields(self, fields):
        self.sudo = CONF.gitlab_users[CONF.bugzilla_users[fields["who"]]]
        # if unable to comment as the original user, put username in comment body
        self.created_at = format_utc(fields["bug_when"])
        if CONF.bugzilla_users[fields["who"]] == CONF.gitlab_misc_user:
            self.body = "By {} on {}\n\n".format(
                fields["who"],
                format_datetime(fields["bug_when"], CONF.datetime_format_string),
            )
        else:
            self.body = format_datetime(fields["bug_when"], CONF.datetime_format_string)
            self.body += "\n\n"

        # if this comment is actually an attachment, upload the attachment and add the
        # markdown to the comment body
        if fields.get("attachid"):
            filename = Attachment.parse_file_description(fields["thetext"])
            attachment_markdown = Attachment(fields["attachid"], filename).save()
            self.body += attachment_markdown
        else:
            self.body += fields["thetext"]

    def validate(self):
        for field in self.required_fields:
            value = getattr(self, field)
            if not value:
                raise Exception("Missing value for required field: {}".format(field))

    def save(self):
        self.validate()
        self.headers["sudo"] = self.sudo
        url = "{}/projects/{}/issues/{}/notes".format(
            CONF.gitlab_base_url, CONF.gitlab_project_id, self.issue_id
        )
        data = {k: v for k, v in self.__dict__.items() if k in self.data_fields}

        _perform_request(
            url,
            "post",
            headers=self.headers,
            data=data,
            json=True,
            dry_run=CONF.dry_run,
            verify=CONF.verify,
        )


class Attachment:
    """
    The attachment model
    """

    def __init__(self, bugzilla_attachment_id, file_description):
        self.id = bugzilla_attachment_id
        self.file_description = file_description
        self.headers = CONF.default_headers

    @classmethod
    def parse_file_description(cls, comment):
        regex = r"^Created attachment (\d*)\s?(.*)$"
        matches = re.match(regex, comment, flags=re.M)
        if not matches:
            raise Exception("Failed to match comment string: {}".format(comment))
        return matches.group(2)

    def parse_file_name(self, headers):
        # Use real filename to store attachment but descriptive name for issue text
        if "Content-disposition" not in headers:
            raise Exception(
                u"No file name returned for attachment {}".format(self.file_description)
            )
        # Content-disposition: application/zip; filename="mail_route.zip"
        regex = r"^.*; filename=\"(.*)\"$"
        matches = re.match(regex, headers["Content-disposition"], flags=re.M)
        if not matches:
            raise Exception(
                "Failed to match file name for string: {}".format(
                    headers["Content-disposition"]
                )
            )
        return matches.group(1)

    def parse_upload_link(self, attachment):
        if not (attachment and attachment["markdown"]):
            raise Exception(
                u"No markdown returned for upload of attachment {}".format(
                    self.file_description
                )
            )
        # ![mail_route.zip](/uploads/e943e69eb2478529f2f1c7c7ea00fb46/mail_route.zip)
        regex = r"^!?\[.*\]\((.*)\)$"
        matches = re.match(regex, attachment["markdown"], flags=re.M)
        if not matches:
            raise Exception(
                "Failed to match upload link for string: {}".format(
                    attachment["markdown"]
                )
            )
        return matches.group(1)

    def save(self):
        url = "{}/attachment.cgi?id={}".format(CONF.bugzilla_base_url, self.id)
        result = _perform_request(url, "get", json=False, verify=CONF.verify)
        filename = self.parse_file_name(result.headers)

        url = "{}/projects/{}/uploads".format(
            CONF.gitlab_base_url, CONF.gitlab_project_id
        )
        f = {"file": (filename, result.content)}
        attachment = _perform_request(
            url,
            "post",
            headers=self.headers,
            files=f,
            json=True,
            dry_run=CONF.dry_run,
            verify=CONF.verify,
        )
        # For dry run, nothing is uploaded, so upload link is faked just to let the process continue
        upload_link = (
            self.file_description
            if CONF.dry_run
            else self.parse_upload_link(attachment)
        )

        return u"[{}]({})".format(self.file_description, upload_link)


def validate_user(bugzilla_user):
    if bugzilla_user not in CONF.bugzilla_users:
        raise Exception(
            "Bugzilla user `{}` not found in user_mappings.yml. "
            "Please add them before continuing.".format(bugzilla_user)
        )
