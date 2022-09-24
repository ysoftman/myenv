#!/bin/bash
# ysoftman
# backup my settings
mkdir -p vscode_settings
if [[ $(uname -a | grep -i darwin) ]]; then
    # backup my brew installed package list and make install script
    install_file="installbrew.sh"
    echo '#!/bin/bash' > ${install_file}
    printf "brew tap homebrew/cask-fonts\n" >> ${install_file}
    printf "brew install " >> ${install_file}
    brew list | sort | tr '\n' ' ' >> ${install_file}

    # backup vscode settings
    cp -v ~/Library/Application\ Support/Code/User/*.json ./vscode_settings/

elif [[ $(uname -a | grep -i microsoft) ]]; then
    # backup vscode settings
    username=$(wslvar userprofile | tr '\\' ' ' | awk '{print $NF}')
    # 윈도우 wsl 에서 mnt/c 로 마운트되었다고 가정
    # 실제 위치 C:\Users\${username}\AppData\Roaming\Code\User\settings.json
    vscode_setting_path="/mnt/c/Users/${username}/AppData/Roaming/Code/User/"
    cp -v ${vscode_setting_path}/*.json ./vscode_settings/

else
    echo 'unknown system'
    exit 1
fi


# backup my pip installed package list and make install script
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

# backup cargo installed package list and make install script
install_file="installcargo.sh"
echo '#!/bin/sh' > ${install_file}
echo 'rustup update' >> ${install_file}
cargo install --list | awk 'NR%2==0 {$1=$1;print}' | tr '\n' ' ' | sed 's/^/cargo install /g' >> ${install_file}
