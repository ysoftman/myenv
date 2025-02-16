#!/bin/bash

if command -v nvim >/dev/null; then
    echo "nvim(neovim) is already installed."
    exit
fi

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install neovim
    exit
elif [[ $os_name == *"linux"* ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

    cat <<EOF
Then add this to your shell config (~/.bashrc, ~/.zshrc, ...):
export PATH="\$PATH:/opt/nvim-linux-x86_64/bin"
EOF
else
    echo "unknown os:$os_name"
fi
