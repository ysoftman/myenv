#!/bin/bash

# ubuntu 18 등에서 시스템에 최신 nodejs 를 설치할 경우
if [[ $(uname | tr "[:upper:]" "[:lower:]") == *"linux"* ]]; then
    node_target="node-v20.16.0-linux-x64"
    wget "https://nodejs.org/dist/v20.16.0/${node_target}.tar.xz"
    tar -Jxvf $node_target.tar.xz
    rm -rf $node_target.tar.xz
    sudo mv -v $node_target /usr/share/
    sudo ln -sf /usr/share/$node_target/bin/node /usr/bin/node
    sudo ln -sf /usr/share/$node_target/bin/npm /usr/bin/npm
    sudo ln -sf /usr/share/$node_target/bin/npx /usr/bin/npx
fi
