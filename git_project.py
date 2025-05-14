#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
github issue 파악
github API 참고
https://docs.github.com/en/rest/projects/projects#list-organization-projects
https://docs.github.com/en/enterprise-server@2.22/rest/reference/projects
"""

import json
import os
import subprocess
import sys

import requests


class color:
    reset_color = "\033[0m"
    black = "\033[0;30m"
    red = "\033[0;31m"
    green = "\033[0;32m"
    yellow = "\033[0;33m"
    blue = "\033[0;34m"
    purple = "\033[0;35m"
    cyan = "\033[0;36m"
    white = "\033[0;37m"


user = ""
password = ""
baseURL = ""
owner = ""
repo = ""


def load_config(git_remote_url):
    cfgFile = os.path.expanduser("~") + "/.git-credentials"
    try:
        f = open(cfgFile, "r")
    except BaseException:
        print("can't find ", cfgFile)
        print(
            cfgFile,
            """에 다음 예시 처럼 접근 관련 정보가 있어야 합니다.
https://ysoftman:password@aaa.github.com
https://ysoftman:password@bbb.github.com
""",
        )
        return False

    cfgs = {}
    while True:
        line = f.readline()
        if not line or line[0] == "\n":
            break

        line = line.strip()  # remove \n
        ele = line.split("@")
        idpw = ele[0].split("//")[1].split(":")
        cfgs[ele[0].split("//")[0] + "//" + ele[1]] = {
            "user": idpw[0],
            "password": idpw[1],
        }

    global user
    global password
    global baseURL
    global owner
    global repo

    if git_remote_url[len(git_remote_url) - 1] == "/":
        git_remote_url = git_remote_url[: len(git_remote_url) - 1]
    findindex = git_remote_url.find(".git")
    if findindex > 0:
        git_remote_url = git_remote_url[:findindex]
    baseURL = git_remote_url.rsplit("/", 2)[0]
    owner = git_remote_url.rsplit("/", 2)[-2]
    repo = git_remote_url.rsplit("/", 1)[-1]
    for key, value in cfgs.items():
        if key == baseURL:
            user = value["user"]
            password = value["password"]
            break
    f.close()
    print(f"baseURL: {baseURL}")
    print(f"owner: {owner}")
    print(f"repo: {repo}")
    print(f"user: {user}")
    # print(f"password: {password}")
    if (
        len(user) == 0
        or len(password) == 0
        or len(baseURL) == 0
        or len(owner) == 0
        or len(repo) == 0
    ):
        print("can't find the user/password about ->", git_remote_url)
        return False

    return True


def get_user_project_url():
    if baseURL == "https://github.com":
        return "https://api.github.com/users/{}/projects".format(owner)
    # for github enterprise
    return "{}/api/v3/users/{}/projects".format(baseURL, owner)


def get_org_project_url():
    if baseURL == "https://github.com":
        return "https://api.github.com/orgs/{}/projects".format(owner)
    # for github enterprise
    return "{}/api/v3/orgs/{}/projects".format(baseURL, owner)


def get_project_url(id: int):
    if baseURL == "https://github.com":
        return "https://api.github.com/projects/{}".format(id)
    # for github enterprise
    return "{}/api/v3/projects/{}".format(baseURL, id)


def org_project_list():
    resp = requests.get(get_org_project_url(), auth=(user, password))
    result = json.loads(resp.content)
    if type(result) is not list:
        print("organization projects not found!, Let's try to get user projects...")
        resp = requests.get(get_user_project_url(), auth=(user, password))
        result = json.loads(resp.content)
        if type(result) is not list:
            return

    for item in result:
        print(f"{color.green}{item['id']} {item['name']}{color.reset_color}")


def get_project(project_id: int):
    resp = requests.get(get_project_url(project_id), auth=(user, password))
    project = json.loads(resp.content)
    if type(project) is not dict:
        print(f"{project_id} project not found!")
        return

    print(f"{color.green}{project['name']}{color.reset_color}")

    resp = requests.get(project["columns_url"], auth=(user, password))
    columns = json.loads(resp.content)
    if type(columns) is not list:
        print(f"{project_id} project not found!")
        return

    # project-columns
    info_columns = []
    for column in columns:
        if "cards_url" in column:
            cards_resp = requests.get(
                column["cards_url"], auth=(user, password), params="per_page=100"
            )
            cards = json.loads(cards_resp.content)
            info_issues = []
            for card in cards:
                # print(card["content_url"])
                # continue
                if "content_url" in card:
                    content_resp = requests.get(
                        card["content_url"], auth=(user, password)
                    )
                    content = json.loads(content_resp.content)
                    assignees = []
                    for i in content["assignees"]:
                        assignees.append(i["login"])
                    issue = {
                        "created_at": content["created_at"],
                        "title": content["title"],
                        "html_url": content["html_url"],
                        "assignee_users": assignees,
                    }
                    assignee_users_str = ",".join(assignees)
                    print(
                        "collecting... "
                        + color.yellow
                        + column["name"]
                        + color.reset_color,
                        # color.cyan + issue["created_at"] + color.reset_color,
                        color.purple + issue["title"] + color.reset_color,
                        color.green + issue["html_url"] + color.reset_color,
                        color.blue + assignee_users_str + color.reset_color,
                    )
                    info_issues.append(issue)
            info_columns.append({column["name"]: info_issues})
    # print(columns)

    # summary...
    print("-----")
    columns_cnt = {}
    user_issue_cnt = {}
    not_assigned_issue_cnt = 0
    not_assigned_issues = []
    for col in info_columns:
        for colname, issues in col.items():
            for issue in issues:
                if colname not in columns_cnt:
                    columns_cnt[colname] = 1
                else:
                    columns_cnt[colname] += 1
                if len(issue["assignee_users"]) == 0:
                    not_assigned_issue_cnt += 1
                    temp = "{} {} {}".format(colname, issue["title"], issue["html_url"])
                    not_assigned_issues.append(temp)
                    continue
                for username in issue["assignee_users"]:
                    if username not in user_issue_cnt:
                        user_issue_cnt[username] = 1
                    else:
                        user_issue_cnt[username] += 1

    for i in columns_cnt:
        print(f"{color.green}{i}: {columns_cnt[i]}{color.reset_color}")
    for i in user_issue_cnt:
        print(f"{color.cyan}{i}: {user_issue_cnt[i]}{color.reset_color}")

    not_assigned_issues_str = "\n".join(not_assigned_issues)
    print(
        f"{color.yellow}not assigned issues: {not_assigned_issue_cnt}\n{not_assigned_issues_str}{color.reset_color}"
    )
    return


if __name__ == "__main__":
    # print(os.getcwd())
    # print(os.path.expanduser('~'))
    git_remote_url = subprocess.Popen(
        "git remote -v | awk 'NR==1 {print $2}'", shell=True, stdout=subprocess.PIPE
    ).stdout.read()
    if load_config(git_remote_url.decode().rstrip()) is False:
        exit(0)

    if len(sys.argv) == 2:
        project_id = sys.argv[1]
        get_project(project_id)
    else:
        org_project_list()
