#!/bin/bash
# ysoftman

# backup my vscode settings
mkdir -p vscode_settings
if [[ $(uname -a | grep -i microsoft) ]]; then
    # backup vscode settings
    username=$(wslvar userprofile | tr '\\' ' ' | awk '{print $NF}')
    # 윈도우 wsl 에서 mnt/c 로 마운트되었다고 가정
    # 실제 위치 C:\Users\${username}\AppData\Roaming\Code\User\settings.json
    vscode_setting_path="/mnt/c/Users/${username}/AppData/Roaming/Code/User/"
    cp -v ${vscode_setting_path}/*.json ./vscode_settings/
fi

# backup my brew installed package list and make install script
if which brew; then
    install_file="installbrew.sh"
    echo '#!/bin/bash' >${install_file}
    printf "brew tap homebrew/cask-fonts\n" >>${install_file}
    printf "brew install " >>${install_file}
    brew list | sort | tr '\n' ' ' >>${install_file}
fi

# backup my pip installed package list and make install script
if command -v uv >/dev/null 2>&1; then
    PIP="uv pip"
fi

if [[ $PIP != 'NONE' ]]; then
    install_file="installpip.sh"
    pip_list=$(${PIP} list | sed -n '3,$p' | awk '{print $1}' | tr '\n' ' ')
    cat <<zzz >${install_file}
#!/bin/bash
# pip 가 없을때 설치
# python -m ensurepip --upgrade
# python -m pip install --upgrade pip
PIP="pip"
# uv(extremely fast Python package and project manager)
# https://github.com/astral-sh/uv
if command -v uv >/dev/null 2>&1; then
    PIP="uv pip"
    additional_for_uv_pip_option="--system"
fi
\${PIP} install --upgrade pip \${additional_for_uv_pip_option}
\${PIP} install $pip_list \${additional_for_uv_pip_option}
zzz

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

# cargo packages 는 installcargo.sh 로 관리
# vim plugins 는 .vimrc 로 관리
