#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

# go install, brew install 로 중복 설치된 패키지 찾기
find_duplicated_packages_in_go_and_brew() {
    local brew_pkgs=()
    local go_pkgs=()
    brew_pkgs+=($(brew list | sort))
    go_pkgs+=($(ls ${GOPATH}/bin | sort))
    IFS_BAK=$IFS
    IFS=$'\n'
    for b in ${brew_pkgs}; do
        for g in ${go_pkgs}; do
            #echo "[brew]$b --- [go]$g"
            if [[ "$b" == "$g" ]]; then
                echo "$b is duplicated package in go and brew"
            fi
        done
    done
    IFS=$IFS_BAK
}
