#!/bin/bash

if [ ! -f "${HOME}/.fzf/bin/fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi
