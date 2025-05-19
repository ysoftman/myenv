#!/bin/bash

if [[ ! -d $HOME/workspace ]]; then
    echo "$HOME/workspace doesn't exists"
    exit 1
fi
cd $HOME/workspace || exit

git_clone_and_pull() {
    git clone ${1}
    targetdir=$(echo ${1} | sed 's/^.*ysoftman\///' | sed 's/\.git$//')
    git -C ~/workspace/${targetdir} pull
}

# 목록 취합은 git_find_ysoftman_dirs.sh 사용
git_clone_and_pull https://github.com/ysoftman/aleng
git_clone_and_pull https://github.com/ysoftman/codingtest.git
git_clone_and_pull https://github.com/ysoftman/colorfulURL.git
git_clone_and_pull https://github.com/ysoftman/coretemp
git_clone_and_pull https://github.com/ysoftman/cutstring
git_clone_and_pull https://github.com/ysoftman/dvc_test
git_clone_and_pull https://github.com/ysoftman/enchash
git_clone_and_pull https://github.com/ysoftman/git-lfs-test.git
git_clone_and_pull https://github.com/ysoftman/github_webhook_action.git
git_clone_and_pull https://github.com/ysoftman/myenv.git
git_clone_and_pull https://github.com/ysoftman/ohmystock.git
git_clone_and_pull https://github.com/ysoftman/taja
git_clone_and_pull https://github.com/ysoftman/test_code
git_clone_and_pull https://github.com/ysoftman/watchDust
git_clone_and_pull https://github.com/ysoftman/ysoftman
git_clone_and_pull https://github.com/ysoftman/ysoftman-lemon.git
git_clone_and_pull https://github.com/ysoftman/ysoftman.github.io
