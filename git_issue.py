#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
github issue 파악
github API 참고 : https://developer.github.com/enterprise/2.13/v3/issues/#list-issues
"""

import requests
import json
import subprocess
import os


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
issue_base_url = ""
open_issue_url = ""


def load_config(git_remote_url):
    cfgFile = os.path.expanduser("~") + "/git_issue_config.json"
    try:
        f = open(cfgFile)
    except:
        print("can't find ", cfgFile)
        print(
            cfgFile,
            """에 다음 예시 처럼 접근 관련 정보가 있어야 합니다.
[
    {
        "user": "ysoftman",
        "passwd": "abc123",
        "baseURL": "https://github.com/",
        "owner": "ysoftman1",
    },
    {
        "user": "ysoftman",
        "passwd": "abc123",
        "baseURL": "https://github.com/",
        "owner": "ysoftman2",
    }
]
""",
        )
        return False

    items = json.load(f)

    global user
    global password
    global baseURL
    global owner
    global repo
    global issue_base_url
    global open_issue_url

    for i in items:
        temp = i["baseURL"] + "/" + i["owner"]
        # print(temp, len(temp))
        git_remote_url = git_remote_url.rstrip("/")
        # print(git_remote_url)
        if git_remote_url.startswith(temp):
            user = i["user"]
            password = i["passwd"]
            baseURL = i["baseURL"]
            owner = i["owner"]
            repo = git_remote_url.rsplit("/", 1)[1]
            # print("user:", user)
            # print("password:", password)
            # print("baseURL:", baseURL)
            # print("owner:", owner)
            # print("git_remote_url:", git_remote_url)
            # print("repo:", repo)
            break
        f.close()

    if (
        len(user) == 0
        or len(password) == 0
        or len(baseURL) == 0
        or len(owner) == 0
        or len(repo) == 0
    ):
        print("can't find the user/password about ->", git_remote_url)
        return False

    issue_base_url = "{}/{}/{}/issues/".format(baseURL, owner, repo)
    if baseURL == "https://github.com":
        # print("[https://api.github.com]")
        open_issue_url = "https://api.github.com/repos/{}/{}/issues?state=open".format(
            owner, repo
        )
    else:
        # for github enterprise
        open_issue_url = "{}/api/v3/repos/{}/{}/issues?state=open".format(
            baseURL, owner, repo
        )

    return True


def issue_list():
    resp = requests.get(open_issue_url, auth=(user, password))
    result = json.loads(resp.content)

    if type(result) != list:
        print("issue not found!")
        exit(0)

    for item in result:
        assignees = []
        for i in item["assignees"]:
            assignees.append(i["login"])
        assignee_users = ",".join(assignees)
        print(
            color.cyan + item["created_at"] + color.reset_color,
            color.yellow + item["state"] + color.reset_color,
            color.purple + item["title"] + color.reset_color,
            color.green + item["html_url"] + color.reset_color,
            color.blue + assignee_users + color.reset_color,
        )


if __name__ == "__main__":
    # print(os.getcwd())
    # print(os.path.expanduser('~'))
    git_remote_url = subprocess.Popen(
        "git remote -v | awk 'NR==1 {print $2}'", shell=True, stdout=subprocess.PIPE
    ).stdout.read()
    if load_config(git_remote_url.decode().rstrip()) == True:
        issue_list()
