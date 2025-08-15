#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

# go install, brew install 로 중복 설치된 패키지 찾기
find_duplicated_packages_in_go_and_brew() {
    local brew_pkgs=()
    local go_pkgs=()
    # brew_pkgs+=($(brew list | sort))  # shellcheck 경고 발생
    while IFS= read -r line; do
        brew_pkgs+=("$line")
    done < <(brew list | sort)
    # go_pkgs+=($(ls ${GOPATH}/bin | sort)) # shellcheck 경고 발생
    while IFS= read -r line; do
        go_pkgs+=("$line")
    done < <(ls ${GOPATH}/bin | sort)
    IFS_BAK=$IFS
    IFS=$'\n'
    local cnt=0
    for b in "${brew_pkgs[@]}"; do
        for g in "${go_pkgs[@]}"; do
            if [[ "$b" == "$g" ]]; then
                echo "${green}$b${reset_color} is duplicated package in go and brew"
            fi
        done
    done
    IFS=$IFS_BAK
}
