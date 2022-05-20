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


def load_config(git_remote_url):
    cfgFile = os.path.expanduser("~") + "/.git-credentials"
    try:
        f = open(cfgFile, "r")
    except:
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
    # print(baseURL)
    # print(owner)
    # print(repo)
    for key, value in cfgs.items():
        if key == baseURL:
            user = value["user"]
            password = value["password"]
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

    return True


def get_open_issue_url():
    if baseURL == "https://github.com":
        # print("[https://api.github.com]")
        return "https://api.github.com/repos/{}/{}/issues?state=open".format(
            owner, repo
        )
    # for github enterprise
    return "{}/api/v3/repos/{}/{}/issues?state=open".format(baseURL, owner, repo)


def issue_list():
    resp = requests.get(get_open_issue_url(), auth=(user, password))
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
