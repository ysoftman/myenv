#!/bin/bash

# TPM(tmux plugin manager) 설치
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed in ~/.tmux/plugins/tpm"
fi
