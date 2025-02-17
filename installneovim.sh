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
    base_version="2.29"
    cur_version=$(ldd --version | head -1 | awk '{print $4}')
    highest_version="$(echo -e "${cur_version}\n${base_version}" | sort -r | head -n1)"
    if [[ ${highest_version} != "${cur_version}" ]]; then
        echo "cur_version:$cur_version < ${base_version}"
        echo "download neovim old verison"
        filename="nvim-linux64"
        url="https://github.com/neovim/neovim/releases/download/v0.9.2/$filename.tar.gz"
    else
        echo "cur_version:$cur_version >= ${base_version}"
        echo "download neovim latest verison"
        filename="nvim-linux-x86_64"
        url="https://github.com/neovim/neovim/releases/latest/download/$filename.tar.gz"
    fi

    curl -LO $url
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf $filename.tar.gz

    cat <<EOF
Then add this to your shell config (~/.bashrc, ~/.zshrc, ...):
export PATH="\$PATH:/opt/$filename/bin"
EOF
else
    echo "unknown os:$os_name"
fi
