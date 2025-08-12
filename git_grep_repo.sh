#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

# git 정보 파악할때 사용
git_grep_repo() {
    # 특정 repo url 만 파악할 경우 인자 추가
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
    for dir in $(fd -H -I -d 2 ".git$" | awk -F "/.git" "{print \$1}"); do
        printf "${green}[%s]==> $reset_color" "$dir"
        git -C "$dir" pull
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
        targetdir=$(echo ${1} | sed 's/^.*ysoftman\///' | sed 's/\.git$//')
        git -C ~/workspace/${targetdir} pull
    }

    # 목록 취합은 git_grep_repo() 사용
    git_clone_and_pull https://github.com/ysoftman/aleng
    git_clone_and_pull https://github.com/ysoftman/codingtest.git
    git_clone_and_pull https://github.com/ysoftman/colorfulURL.git
    git_clone_and_pull https://github.com/ysoftman/confetty
    git_clone_and_pull https://github.com/ysoftman/coretemp
    git_clone_and_pull https://github.com/ysoftman/cutstring
    git_clone_and_pull https://github.com/ysoftman/dvc_test
    git_clone_and_pull https://github.com/ysoftman/enchash
    git_clone_and_pull https://github.com/ysoftman/git-lfs-test.git
    git_clone_and_pull https://github.com/ysoftman/github_webhook_action.git
    git_clone_and_pull https://github.com/ysoftman/myenv.git
    git_clone_and_pull https://github.com/ysoftman/ohmystock.git
    git_clone_and_pull https://github.com/ysoftman/taja
    git_clone_and_pull https://github.com/ysoftman/test_code
    git_clone_and_pull https://github.com/ysoftman/watchDust
    git_clone_and_pull https://github.com/ysoftman/ysoftman
    git_clone_and_pull https://github.com/ysoftman/ysoftman-lemon.git
    git_clone_and_pull https://github.com/ysoftman/ysoftman.github.io
}

# ysoftman 저장소를 사용하는 소스들의 로컬 git 설정
git_local_settings_for_ysoftman() {
    if [[ ! -d $HOME/workspace ]]; then
        echo "$HOME/workspace doesn't exists"
        exit 1
    fi
    cd $HOME/workspace || exit
    if [ "$(which fd)" ]; then
        echo "using fd..."
        gitdirs=$(fd -E "*gopath*" -E "*chromium*" -E "*node_module*" '\.git$' --hidden --no-ignore --type d .)
    else
        echo "using find..."
        gitdirs=$(find . -name .git -type d)
    fi

    if [ "$(which rg)" ]; then
        echo "using rg(ripgrep)"
        grep="rg"
    else
        echo "using grep"
        grep="grep"
    fi

    # for item in `cat gitdirs`
    for item in ${(f)gitdirs}; do
        out=$(git -C ${item} remote -v | ${grep} -c "https://github.com/ysoftman/" | awk '{print $1}')
        if [[ $out == 2 ]]; then
            # echo $item
            cat <<zzz
git -C ${item} config user.email "ysoftman@gmail.com"
git -C ${item} config user.name "ysoftman"
zzz
            git -C ${item} config user.email "ysoftman@gmail.com"
            git -C ${item} config user.name "ysoftman"
        fi
    done
}
