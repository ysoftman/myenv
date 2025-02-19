#!/bin/bash

fzf_cmd=$(command -v fzf 2>/dev/null)
if [ ! -z $fzf_cmd ]; then
    echo $fzf_cmd already exists.
    exit 0
fi

if [ ! -f "${HOME}/.fzf/bin/fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    #  설치되면 ~/.fzf.zsh ~/.fzf.bash 가 생성되고 각각 .zshrc, .bashrc 에서 로딩되어 ~/.fzf/bin/ 경로가 추가된다.
fi
