#!/bin/bash

cd ~/workspace
if [[ $? != 0 ]]; then
    echo "~/workspace doesn't exists"
    exit 1
fi

git_clone_and_pull()
{
    git clone ${1}
    targetdir=`echo ${1} | sed 's/^.*ysoftman\///' | sed 's/\.git$//'`
    git -C ~/workspace/${targetdir} pull
}

# git repo url 추출은 git_url.sh 참고
git_clone_and_pull https://github.com/ysoftman/aleng
git_clone_and_pull https://github.com/ysoftman/codingtest.git
git_clone_and_pull https://github.com/ysoftman/colorfulURL
git_clone_and_pull https://github.com/ysoftman/cutstring
git_clone_and_pull https://github.com/ysoftman/enchash
git_clone_and_pull https://github.com/ysoftman/myenv
git_clone_and_pull https://github.com/ysoftman/ohmystock.git
git_clone_and_pull https://github.com/ysoftman/taja
git_clone_and_pull https://github.com/ysoftman/test_code
git_clone_and_pull https://github.com/ysoftman/watchDust
git_clone_and_pull https://github.com/ysoftman/ysoftman.github.io
