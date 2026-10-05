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
for zsh_path in /opt/homebrew/bin/zsh /usr/local/bin/zsh /usr/bin/zsh /bin/zsh; do
    [ -x "${zsh_path}" ] && break
    zsh_path=""
done
if [ -z "${zsh_path}" ]; then
    echo 'can not find zsh'
    exit 1
fi
# brew, 소스 빌드로 설치한 zsh 는 /etc/shells 에 자동 등록되지 않는다.
grep -qxF "${zsh_path}" /etc/shells || echo "${zsh_path}" | ${sudo_cmd} tee -a /etc/shells
${sudo_cmd} chsh -s "${zsh_path}" "${USER}"
