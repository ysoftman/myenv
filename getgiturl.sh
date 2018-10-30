#!/bin/bash

cd ~/workspace
if [[ $? != 0 ]]; then
    echo "~/workspace doesn't exists"
    exit 1
fi

# 특정 repo url 만 파악할 경우 인자 추가
grepgit="github.com/ysoftman"
if (( $# > 0 )); then
    grepgit=${1}
fi
echo "grep_git_repo=${grepgit}"

# 현재 사용중인 git 정보 파악할때 사용
get_git_url()
{
    gitdirs=$(find . -name .git -not -path \*gopath\* -not -path \*chromium\* | sed "s/.git$//")
    for i in ${gitdirs}
    do
        git -C ${i} remote -v | head -1 | awk '{print $2}' | grep ${grepgit}
    done
}

get_git_url
