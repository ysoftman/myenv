#!/bin/bash
# ysoftman
# backup my settings
mkdir -p vscode_settings
if [[ $(uname -a | grep -i darwin) ]]; then
    # backup my brew list and make install script
    install_file="installbrew.sh"
    echo '#!/bin/bash' > ${install_file}
    printf "brew tap homebrew/cask-fonts\n" >> ${install_file}
    printf "brew cask install font-hack-nerd-font java\n" >> ${install_file}
    printf "brew install " >> ${install_file}
    brew list | sort | tr '\n' ' ' >> ${install_file}

    # backup vscode settings
    cp -v ~/Library/Application\ Support/Code/User/*.json ./vscode_settings/

elif [[ $(uname -a | grep -i microsoft) ]]; then
    # backup vscode settings
    # 윈도우 wsl 에서 mnt/c 로 마운트되었다고 가정
    # 실제 위치 C:\Users\Administrator\AppData\Roaming\Code\User\settings.json
    src_path="/mnt/c/Users/Administrator/AppData/Roaming/Code/User/"
    cp -v ${src_path}/*.json ./vscode_settings/

else
    echo 'unknown system'
    exit 1
fi


# backup my pip list and make install script
install_file="installpip.sh"
echo '#!/bin/bash' > ${install_file}
echo 'sudo pip install --upgrade pip' >> ${install_file}
printf "sudo pip install " >> ${install_file}

PIP='pip'
which ${PIP}
if [ $? -ne 0 ]; then
    PIP='pip2'
    which ${PIP}
    if [ $? -ne 0 ]; then
        PIP='pip3'
        which ${PIP}
        if [ $? -ne 0 ]; then
            echo 'there is no pip'
            PIP='NONE'
        fi
    fi
fi
if [[ $PIP != 'NONE' ]]; then
    echo "PIP=${PIP}"
    ${PIP} list | sed -n '3,$p' | awk '{print $1}' | tr '\n' ' ' >> ${install_file}
fi
# --upgrade 필요시에만 사용
# echo ' --upgrade' >> ${install_file}

# backup .ssh directory
# 보안사항으로 github 저장소에 올리면 안됨.
# mkdir -p .ssh
# cp -v ~/.ssh/* ./.ssh/

# backup hosts
# 보안사항으로 github 저장소에 올리면 안됨.
# cp -v /etc/hosts ./hosts

# backup vscode extension and make install script
install_file="installvscodeextension.sh"
echo '#!/bin/sh' > ${install_file}
code --list-extensions | sed 's/^/code --install-extension /g' >> ${install_file}
