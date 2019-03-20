#!/bin/bash
if [ $(uname) == 'Darwin' ]; then
    cp -fv ./vscode_settings/*.json ~/Library/Application\ Support/Code/User/
elif [ $(uname) == 'Linux' ]; then
    # 윈도우 wsl 에서 mnt/c 로 마운트되었다고 가정
    # 실제 위치 C:\Users\Administrator\AppData\Roaming\Code\User\settings.json
    cp -fv ./vscode_settings/*.json /mnt/c/Users/Administrator/AppData/Roaming/Code/User/
else
    echo 'unknown system'
    exit 1
fi

sh ./installvscodeextension.sh
