#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
github issue 파악
github API 참고 : https://developer.github.com/enterprise/2.13/v3/issues/#list-issues
~/git_issue_config.config 에 접근할 수 있는 url 정보가 있어야 한다.
[
    {
        "user": "ysoftman",
        "passwd": "abc123",
        "baseURL": "https://github.com/",
        "owner": "ysoftman",
        "repo": "myenv"
    },
    {
        "user": "ysoftman",
        "passwd": "abc123",
        "baseURL": "https://github.com/",
        "owner": "ysoftman",
        "repo": "test_code"
    }
]
'''

import requests
import json
import subprocess
import os

class color:
    reset_color = '\033[0m'
    # 일반
    black = '\033[0;30m'
    red = '\033[0;31m'
    green = '\033[0;32m'
    yellow = '\033[0;33m'
    blue = '\033[0;34m'
    purple = '\033[0;35m'
    cyan = '\033[0;36m'
    white = '\033[0;37m'

global user
global passwd
global baseURL
global owner
global repo
global issue_base_url
global open_issue_url

def load_config(git_remote_url):
    f = open(os.path.expanduser('~')+'/git_issue_config.json')
    items = json.load(f)
    global user
    global passwd
    global baseURL
    global owner
    global repo
    global issue_base_url
    global open_issue_url

    for i in items:
        temp = i['baseURL']+'/'+i['owner']+'/'+i['repo']
        # print(temp)
        # print(git_remote_url)
        if git_remote_url == temp:
            user = i['user']
            passwd = i['passwd']
            baseURL = i['baseURL']
            owner = i['owner']
            repo = i['repo']
    f.close()

    issue_base_url = "{}/{}/{}/issues/".format(baseURL, owner, repo)
    open_issue_url = "{}/api/v3/repos/{}/{}/issues?state=open".format(baseURL, owner, repo)
    return True


def issue_list():
    resp = requests.get(open_issue_url, auth=(user, passwd))
    result = json.loads(resp.content)

    for item in result:
        # print(item)
        assignees = []
        for i in item['assignees']:
            assignees.append(i['login'])
        assignee_users = ",".join(assignees)
        print(color.cyan+item['created_at']+color.reset_color,
            color.yellow+item['state']+color.reset_color,
            color.purple+item['title']+color.reset_color,
            color.green+item['html_url']+color.reset_color,
            color.blue+assignee_users+color.reset_color)


if __name__ == '__main__':
    # print(os.getcwd())
    # print(os.path.expanduser('~'))
    git_remote_url = subprocess.Popen("git remote -v | awk 'NR==1 {print $2}'", shell=True,
                              stdout=subprocess.PIPE).stdout.read()
    if load_config(git_remote_url.decode().rstrip()) == True:
        issue_list()
