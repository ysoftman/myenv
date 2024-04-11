#!/bin/bash
if [ $(uname) == 'Darwin' ]; then
    ln -sf ${PWD}/vscode_settings/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
    ln -sf ${PWD}/vscode_settings/locale.json ~/Library/Application\ Support/Code/User/locale.json
    ln -sf ${PWD}/vscode_settings/settings.json ~/Library/Application\ Support/Code/User/settings.json
elif [[ $(uname -r | awk '{print tolower($0)}') == *"wsl"* ]]; then
    echo 'Linux - WSL'
    username=$(wslvar userprofile | tr '\\' ' ' | awk '{print $NF}')
    vscode_setting_path="/mnt/c/Users/${username}/AppData/Roaming/Code/User/"
    if [[ -d ${vscode_setting_path} ]]; then
        # 윈도우 wsl 에서 mnt/c 로 마운트되었다고 가정
        # 실제 위치 C:\Users\${username}\AppData\Roaming\Code\User\settings.json
        ln -sf ${PWD}/vscode_settings/keybindings.json ${vscode_setting_path}/keybindings.json
        ln -sf ${PWD}/vscode_settings/locale.json ${vscode_setting_path}/locale.json
        ln -sf ${PWD}/vscode_settings/settings.json ${vscode_setting_path}/settings.json
    else
        echo "can't find vscode path: ${vscode_setting_path}"
    fi
else
    echo 'unknown system'
    exit 1
fi
