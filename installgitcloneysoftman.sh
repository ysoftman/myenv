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


git_clone_and_pull https://github.com/ysoftman/aleng.git
git_clone_and_pull https://github.com/ysoftman/codingtest.git
git_clone_and_pull https://github.com/ysoftman/cutstring.git
git_clone_and_pull https://github.com/ysoftman/enchash.git
git_clone_and_pull https://github.com/ysoftman/myenv.git
git_clone_and_pull https://github.com/ysoftman/taja.git
git_clone_and_pull https://github.com/ysoftman/test_code.git
git_clone_and_pull https://github.com/ysoftman/ysoftman.github.io.git