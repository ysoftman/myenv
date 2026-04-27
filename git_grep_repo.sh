#!/bin/bash

if [[ -z ${myenv_path} ]]; then
    echo "can't find myenv_path variable"
fi
source "${myenv_path}/colors.sh"

# git 정보 파악할때 사용
git_grep_repo() {
    # 특정 repo url 만 파악할 경우 인자 추가
    local url
    url="https?://github.com/ysoftman"
    if (($# > 0)); then
        url=${1}
    fi
    echo "git_repo=${url}"

    # fd가 속도가 더 빠르다.
    # $(find . -name .git -not -path \*gopath\* -not -path \*chromium\* | sed "s/.git.*$//")

    # gitdirs 변수로 담아두면 zsh 로 for 에서 하나로 취급되어 문제가 된다.
    # 다음과 같이 Parameter Expansion Flags 중 f 를 명시해야 된다.
    # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
    # f : Split the result of the expansion at newlines. This is a shorthand for ‘ps:\n:’.
    # gitdirs=$(fd -H -E "*gopath*" -E "*chromium*" "\.git$" | sed "s/.git.*$//")
    # for i in ${(f)gitdirs}

    # bash / zsh 모두 동작하려면 다음과 같이 리스트 결과를 변수에 담지 않고 for 에서 바로 실행해야 한다.
    # cnt=0
    for i in $(fd -H -I -E "*gopath*" -E "*chromium*" -E "*node_module*" "\.git$" | sed "s#.git/.*##"); do
        # ((cnt++))
        # set -x
        git -C ${i} remote -v | head -1 | awk '{print $2}' | rg -i ${url}
        # set -
        # echo "cnt: $cnt"
    done
}

# 현재 하위 모든 git 디렉토리 pull 받기
git_pull_all() {
    for dir in $(fd -H -I -d 2 ".git$" | sed 's|/\.git/$||; s|^\.git/$|.|'); do
        printf "${green}[%s]==> $reset_color" "$dir"
        git -C "$dir" pull --prune
    done
}

git_clone_ysoftman_repository() {
    if [[ ! -d $HOME/workspace ]]; then
        echo "$HOME/workspace doesn't exists"
        exit 1
    fi
    cd $HOME/workspace || exit

    git_clone_and_pull() {
        git clone ${1}
        local targetdir
        targetdir=$(echo ${1} | sed 's/^.*ysoftman\///' | sed 's/\.git$//')
        git -C ~/workspace/${targetdir} pull
    }

    for url in $(gh repo list ysoftman --source --json url --jq '.[].url' | sort); do
        git_clone_and_pull $url
    done
    git_local_settings_for_ysoftman
}

# ysoftman 저장소를 사용하는 소스들의 로컬 git 설정
git_local_settings_for_ysoftman() {
    if [[ ! -d $HOME/workspace ]]; then
        echo "$HOME/workspace doesn't exists"
        exit 1
    fi
    cd $HOME/workspace || exit
    local gitdirs
    if [ "$(which fd)" ]; then
        echo "using fd..."
        gitdirs=$(fd -E "*gopath*" -E "*chromium*" -E "*node_module*" '\.git$' --hidden --no-ignore --type d .)
    else
        echo "using find..."
        gitdirs=$(find . -name .git -type d)
    fi

    local grep
    if [ "$(which rg)" ]; then
        echo "using rg(ripgrep)"
        grep="rg"
    else
        echo "using grep"
        grep="grep"
    fi

    # for item in `cat gitdirs`
    local out
    local user_email
    local user_name
    user_email="ysoftman@gmail.com"
    user_name="ysoftman"
    for item in ${(f)gitdirs}; do
        out=$(git -C ${item} remote -v | ${grep} -c "https://github.com/ysoftman/" | awk '{print $1}')
        if [[ $out == 2 ]]; then
            # echo $item
            cat <<zzz
git -C ${item} config user.email "${user_email}"
git -C ${item} config user.name "${user_name}"
zzz
            git -C ${item} config user.email "${user_email}"
            git -C ${item} config user.name "${user_name}"
        fi
    done
}
