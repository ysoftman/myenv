#!/bin/bash

# zsh-completions 사용
if [ ! -f "$HOME/.zsh/zsh-completions/src" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
fi
