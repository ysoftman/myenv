#!/bin/bash

cd ~/workspace
if [[ $? != 0 ]]; then
    echo "~/workspace doesn't exists"
    exit 1
fi

git clone https://github.com/ysoftman/aleng.git
git clone https://github.com/ysoftman/codingtest.git
git clone https://github.com/ysoftman/cutstring.git
git clone https://github.com/ysoftman/enchash.git
git clone https://github.com/ysoftman/myenv.git
git clone https://github.com/ysoftman/taja.git
git clone https://github.com/ysoftman/test_code.git
