#!/bin/bash

if [[ -z ${myenv_path} ]]; then
    echo "can't find myenv_path variable"
fi
source "${myenv_path}/colors.sh"

# go install, brew install 로 중복 설치된 패키지 찾기
find_duplicated_packages_in_go_and_brew() {
    # local brew_pkgs=()
    # local go_pkgs=()
    # # brew_pkgs+=($(brew list | sort))  # shellcheck 경고 발생
    # while IFS= read -r line; do
    #     brew_pkgs+=("$line")
    # done < <(brew list | sort)
    # # go_pkgs+=($(ls ${GOPATH}/bin | sort)) # shellcheck 경고 발생
    # while IFS= read -r line; do
    #     go_pkgs+=("$line")
    # done < <(ls ${GOPATH}/bin | sort)
    # IFS_BAK=$IFS
    # IFS=$'\n'
    # local cnt=0
    # for b in "${brew_pkgs[@]}"; do
    #     for g in "${go_pkgs[@]}"; do
    #         if [[ "$b" == "$g" ]]; then
    #             echo "${green}$b${reset_color} is duplicated package in go and brew"
    #         fi
    #     done
    # done
    # IFS=$IFS_BAK

    # comm 3번째열(공통항목)으로 찾기
    duplicated_pkgs=$(comm -12 <(brew list | sort) <(ls ${GOPATH}/bin | sort))
    echo "${green}$duplicated_pkgs${reset_color} is duplicated package in go and brew"
}

find_brew_packages_in_arm64_and_x86_64() {
    pkgs=$(
        comm \
            <(arch -arm64 /opt/homebrew/bin/brew list | sort) \
            <(arch -x86_64 /usr/local/bin/brew list | sort) |
            awk -F'\t' -v cyan="${cyan}" -v purple="${purple}" -v green="${green}" -v reset="${reset_color}" '
    BEGIN {
        OFS="\t"
    }
    {
    # arm64
    if ($1 != "" && $2 == "") {
        print cyan $1 reset
    }
    # x86_64
    else if ($1 == "" && $2 != "") {
        print purple $1,$2 reset
    }
    # common
    else {
        print green $1,$2,$3 reset
    }
}'
    )

    echo -e "${cyan}arm64\t${purple}x86_64\t${green}common${reset_color}"
    echo "$pkgs${reset_color}"
}
