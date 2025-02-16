#!/bin/bash
sudo_cmd='sudo'

# zsh 버전이 낮으면 소스 다운로드 받아 설치하기
cur_version="$(zsh --version | cut -d" " -f2)"
compare_version="5.1.999"
echo 'cur_version='${cur_version}
echo 'compare_version='${compare_version}
highest_version="$(printf "%s\n%s" ${cur_version} ${compare_version} | sort -r | head -n1)"
echo 'highest_version='${highest_version}
if [ "${highest_version}" == "${compare_version}" ]; then
    echo "${compare_version} > ${cur_version}"
    curl -OL https://sourceforge.net/projects/zsh/files/zsh/5.2/zsh-5.2.tar.gz/download
    mv download zsh-5.2.tar.gz
    tar zxvf zsh-5.2.tar.gz
    cd zsh-5.2 || exit
    ./configure && make -j 4 && ${sudo_cmd} make install
    /usr/local/bin/zsh --version
else
    echo "${compare_version} < ${cur_version}"
fi

# 현재 유저의 기본 쉘을 zsh 로 변경
# /etc/shells 는 >> 를 허용하지 않아 수정 파일로 바꿔친다.
${sudo_cmd} cp -fv /etc/shells /etc/shells.bak
${sudo_cmd} cp -fv /etc/pam.d/chsh /etc/pam.d/chsh.bak
${sudo_cmd} cp -fv shells /etc/shells
${sudo_cmd} cp -fv chsh /etc/pam.d/chsh
if [ -x /opt/homebrew/bin/zsh ]; then
    ${sudo_cmd} chsh -s /opt/homebrew/bin/zsh ${USER}
elif [ -x /usr/local/bin/zsh ]; then
    ${sudo_cmd} chsh -s /usr/local/bin/zsh ${USER}
elif [ -x /usr/bin/zsh ]; then
    ${sudo_cmd} chsh -s /usr/bin/zsh ${USER}
elif [ -x /bin/zsh ]; then
    ${sudo_cmd} chsh -s /bin/zsh ${USER}
else
    echo 'can not find zsh'
fi
