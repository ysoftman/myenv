#!/bin/bash

# 현재 사용중인 git 정보 파악할때 사용
git_url()
{
    # 특정 repo url 만 파악할 경우 인자 추가
    grepgit="github.com/ysoftman"
    if (( $# > 0 )); then
        grepgit=${1}
    fi
    echo "grep_git_repo=${grepgit}"

    # fd가 속도가 더 빠르다.
    # $(find . -name .git -not -path \*gopath\* -not -path \*chromium\* | sed "s/.git.*$//")

    # gitdirs 변수로 담아두면 zsh 로 for 에서 하나로 취급되어 문제가 된다.
    # 다음과 같이 Parameter Expansion Flags 중 f 를 명시해야 된다.
    # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
    # f : Split the result of the expansion at newlines. This is a shorthand for ‘ps:\n:’.
    # gitdirs=$(fd -H -E "*gopath*" -E "*chromium*" "\.git$" | sed "s/.git.*$//")
    # for i in ${(f)gitdirs}

    # bash / zsh 모두 동작하려면 다음과 같이 리스트 결괄르 변수에 담지 않고 for 에서 바로 실행해야 한다.
    # cnt=0
    for i in $(fd -H -E "*gopath*" -E "*chromium*" "\.git$" | sed "s/.git.*$//")
    do
        # ((cnt++))
        # set -x
        git -C ${i} remote -v | head -1 | awk '{print $2}' | grep ${grepgit}
        # set -
        # echo "cnt: $cnt"
    done
}
