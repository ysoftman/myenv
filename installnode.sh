#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

if [[ $os_name == *"linux"* ]]; then
    # ubuntu 18 등에서 시스템에 최신 nodejs 를 설치할 경우
    # node_target="node-v20.16.0-linux-x64"
    # wget "https://nodejs.org/dist/v20.16.0/${node_target}.tar.xz"
    # tar -Jxvf $node_target.tar.xz
    # rm -rf $node_target.tar.xz
    # sudo mv -v $node_target /usr/share/
    # sudo ln -sf /usr/share/$node_target/bin/node /usr/bin/node
    # sudo ln -sf /usr/share/$node_target/bin/npm /usr/bin/npm
    # sudo ln -sf /usr/share/$node_target/bin/npx /usr/bin/npx

    # node 버전 관리
    # nvm(Node Version Manager)는 쉘 기반 이라 느려서 mise 로 대체
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    # # restart the terminal
    # nvm install 18

    # volta 유지보수안하고 mise 를 사용하라고 함
    # curl https://get.volta.sh | bash
    # # install Node
    # volta install node

    echo "install mise"
    curl https://mise.run | sh
    ~/.local/bin/mise --version

elif [[ $os_name == *"darwin"* ]]; then
    # brew install nvm
    # brew install volta
    brew install mise
    exit 0
fi
