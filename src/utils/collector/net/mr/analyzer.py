#!/usr/bin/python3

"""
Copyright (c) 2022, Netskope, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Written by Pramod Rana
"""

from github import Github
import datetime
import os
import time
from tabulate import tabulate
import urllib
import urllib.request
import json
import requests
from jira import JIRA
import argparse 


GIT = Github(os.getenv("GITHUB_ACCESS_TOKEN"))

# WAITING_PERIOD will determine the days, after which further action will be triggered
WAITING_PERIOD = 15

# Severity mapping between Dependabot Alerts and Jira
DEPENDABOT_JIRA_SEVERITY = {
	"critical": "Critical",
	"high": "Major",
	"moderate": "Minor",
	"low": "Trivial"
}
DEFAULT_SEVERITY = "Minor"

GRAPHQL_QUERY = '''{
    repository(name: "$repo_name", owner: "$owner_name") {
        vulnerabilityAlerts(last:100, states:OPEN) {
            nodes {
                repository {
                	name
                }
                number
                securityVulnerability {
                    severity
                    advisory {
                    	cvss {
                    		score
                    	}
                    	cwes (first: 5){
                    		nodes {
                    			cweId
                    		}
                    	}
                    }
                }
                dependabotUpdate {
                    pullRequest {
                        title
                        number
                    }
                }
            }
        }
    }
}'''

# In form of "https://<organization_name>.atlassian.net"
JIRA_SERVER = os.getenv("JIRA_SERVER") 

def create_jira_ticket(project,ticket_type,summary,description,components,assignee,priority):
	jira = JIRA(server=JIRA_SERVER,basic_auth=(os.getenv("JIRA_API_USERNAME"),os.getenv("JIRA_API_TOKEN")))
	
	# Modify these parameters according to mandatory fields in your Jira configuration
	new_issue = jira.create_issue(project = {'key': project},
		summary=summary,
		description=description,
		issuetype = {'name': ticket_type},
		assignee = {'name': assignee},
		components = [{'name': components}],
		priority = {'name': priority},
		labels = ["dependabot"])
	
	jira.assign_issue(new_issue,assignee) # this operation requires 'Assign Issue' permission
	# new_issue.update(assignee = {'name': assignee}) # this operation requires 'Edit Issue' permission 
	return new_issue.key

def issue_exist(keyword):
	jira = JIRA(server=JIRA_SERVER,basic_auth=(os.getenv("JIRA_API_USERNAME"),os.getenv("JIRA_API_TOKEN")))
	search_query = 'type = Bug and labels = dependabot and description ~ "' + keyword + '"'
	issue = jira.search_issues(search_query)
	if issue.total > 0:
		return issue[0].key
	else:
		return "Not Found"


def fetch_custom_config(organization_name,repo_name):	
	print ("Fetching the configuration file")

	custom_config_repo = GIT.get_repo(organization_name + "/" + repo_name)
	config_path = "/custom-config.json"
	
	config_download_url = custom_config_repo.get_contents(urllib.parse.quote(config_path)).download_url

	with urllib.request.urlopen(config_download_url) as url_content:
		config_data = json.loads(url_content.read().decode())
	time.sleep(3)
	
	print ("Custom configuration fetched")
	return config_data

SECURITY_ALERT_OUTPUT = []

def enable_dependabot_alert(organization_name, repo_name):
	repo = GIT.get_repo(organization_name + "/" + repo_name)
	if not (repo.get_vulnerability_alert() or repo.archived):
		SECURITY_ALERT_OUTPUT.append([str(repo.name),str(repo.html_url),str(repo.enable_automated_security_fixes())])
		# print (str(repo.name) + " : " + str(repo.html_url) + " : Enabled: " + str(repo.enable_automated_security_fixes())) # enable automatically
		time.sleep(3)


def file_jira_ticket(jira_project,pr,jira_component,owner_email,severity,cvss,cwestring):
	ticket_number = "NA" # Implies Configuration Not Found
	if jira_project != "":
		ticket_number = issue_exist(pr.html_url)
		if "Not Found" in ticket_number:
			try:
				project = jira_project
				ticket_type = "Bug"
				summary = "Dependabot Pull Request Review - Repo: " + str(pr.repository.name) + " & Components: " + str(jira_component)
				description = "Please review below pull request as vulnerability has been discovered within your code base.\nOwner: " + str(owner_email) + "\nPull Request: " + str(pr.html_url) + "\nSeverity: " + str(severity) + "\nCVSS: " + str(cvss) + "\nCWEs: " + str(cwestring)
				components = jira_component
				assignee = str(owner_email).split(",")[0]
				try:
					priority = DEPENDABOT_JIRA_SEVERITY[str(severity).lower()]
				except:
					priority = DEFAULT_SEVERITY
				ticket_number = create_jira_ticket(project,ticket_type,summary,description,components,assignee,priority) 
			except Exception as ex:
				ticket_number = str(ex.text)
	return ticket_number

def overall_trend_analysis(organization_name):
	months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

	today_date = datetime.date.today()
	trend_output = []

	for month in range(1,today_date.month + 1):
		first_day = datetime.date(today_date.year,month,1)
		if month > 11:
			last_day = datetime.date(today_date.year + 1,1,1) - datetime.timedelta(days=1)
		else:
			last_day = datetime.date(today_date.year,month + 1,1) - datetime.timedelta(days=1)
		
		query = "is:pr label:dependencies user:" + organization_name +" is:open created:" + str(first_day) + ".." + str(last_day)
		open_count = GIT.search_issues(query).totalCount
		time.sleep(5)

		query = "is:pr label:dependencies user:" + organization_name +" closed:" + str(first_day) + ".." + str(last_day)
		close_count = GIT.search_issues(query).totalCount
		time.sleep(5)
		trend_output.append([str(months[month-1]) + "-" + str(today_date.year),str(open_count),str(close_count)])

	print (tabulate(trend_output,headers=["Month","Opened PRs","Closed PRs"]))


# Main function starts here # 

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("-o","--organization", help="Github Organization Name")
	parser.add_argument("-r","--config-repo", help="Custom Configuration Repository Name")
	parser.add_argument("-w","--waiting-period", type=int, help="Waiting Period (default 15)")
	parser.add_argument("-c","--config-organization", help="Custom Configuration Organization Name (default set to Github Organization Name)")
	
	args = parser.parse_args()
	if args.organization:
	    organization = args.organization
	    config_organization = args.organization
	else:
		parser.print_help()
		exit(0)
	
	if args.config_repo:
		config_repo = args.config_repo
	else:
		parser.print_help()
		exit(0)

	if args.config_organization:
		config_organization = args.config_organization

	if args.waiting_period:
		WAITING_PERIOD = args.waiting_period

	config_data = fetch_custom_config(config_organization,config_repo)

	print ("Dependabot PRs with created date > " + str(WAITING_PERIOD) + " days")
	print ("--------------------------------------------------------------------------------------------------------")

	repos = GIT.get_organization(organization).get_repos()

	waiting_days_output = []
	waiting_days = (datetime.datetime.now() - datetime.timedelta(days = WAITING_PERIOD)).date()

	for repo in repos:
		enable_dependabot_alert(organization,repo.name)
		response = requests.post('https://api.github.com/graphql', data=json.dumps({'query': GRAPHQL_QUERY.replace("$repo_name",str(repo.name)).replace("$owner_name",str(organization))}), headers={'Authorization': 'bearer ' + str(os.getenv("GITHUB_ACCESS_TOKEN")) ,'Accept': 'application/vnd.github.vixen-preview+json'})
		json_alert_data = response.json()
		time.sleep(5)

		query = "is:pr label:dependencies repo:" + str(organization) + "/" + str(repo.name) + " is:open created:<="+ str(waiting_days)
		waiting_days_open_pr = GIT.search_issues(query)
		print ("Repo " + str(repo.name) + " total PRs: " + str(waiting_days_open_pr.totalCount))
		for pr in waiting_days_open_pr:
			cvss = ""
			cwestring = ""
			jira_component = ""
			jira_project = ""
			owner_email = ""
			severity = ""
			repo_name = str(pr.repository.name)
			for config_line in config_data['config']:
				if config_line['repo'] == repo_name:
					jira_component = str(config_line['jira_component'])
					jira_project = str(config_line['jira_project'])
					owner_email = str(config_line['owner_email'])
					break

			for alert in json_alert_data["data"]["repository"]["vulnerabilityAlerts"]["nodes"]:
				try:
					if alert["dependabotUpdate"]["pullRequest"]["number"] == pr.number:
						severity = alert["securityVulnerability"]["severity"]
						cvss = alert["securityVulnerability"]["advisory"]["cvss"]["score"]
						cwestring = ""
						for cwe in alert["securityVulnerability"]["advisory"]["cwes"]["nodes"]:
							cwestring = cwestring + str(cwe["cweId"]) + ", "
						break
				except Exception as ex:
					error = str(ex)
			
			ticket_number = file_jira_ticket(jira_project,pr,jira_component,owner_email,severity,cvss,cwestring)
				
			waiting_days_output.append([str(pr.title),str(pr.created_at),str(pr.updated_at),str(pr.html_url),str(jira_project),str(jira_component),str(owner_email),str(cvss),str(severity),str(cwestring),str(ticket_number)])
			# print "\tTitle: " + str(pr.title) + " && Assignee: " + str(pr.assignee) + " && Created at: " + str(pr.created_at) + " && Updated at: " + str(pr.updated_at) + " && Ref: " + str(pr.html_url)
			time.sleep(3) # adding sleep to avoid Github rate limit constraint

	print (tabulate(waiting_days_output,headers=["Title","Created at","Updated at","Link","Jira Project", "Jira Components","Owner Email","CVSS","Severity","CWEs","Jira Ticket"]))


	print ("Repositories where 'Security Alert' is disabled and repository is not Archived")
	print ("--------------------------------------------------------------------------------------------------------")

	print(tabulate(SECURITY_ALERT_OUTPUT,headers=["Repository Name","Repository Path","Enabled Successful"]))

	query = "is:pr label:dependencies user:" + organization +" is:open"

	print ("Trend Analysis For Current Year | " + "Total Open Dependabot PRs: " + str(GIT.search_issues(query).totalCount))
	print ("--------------------------------------------------------------------------------------------------------")
	
	overall_trend_analysis(organization)
