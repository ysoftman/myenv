#!/bin/bash

# zsh-completions 사용
if [ ! -d "$HOME/.zsh/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
    exit 0
else
    cd ~/.zsh/zsh-completions/ || exit 1
    git pull
    exit 0
fi
