#!/bin/bash

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install neovim
    exit
elif [[ $os_name == *"linux"* ]]; then
    echo "download neovim latest version"
    filename="nvim-linux-x86_64"
    rm -rf $HOME/$filename
    curl -LO "https://github.com/neovim/neovim/releases/latest/download/$filename.tar.gz"
    tar -C $HOME/ -xzf $filename.tar.gz

    cat <<EOF
myenv.sh 에서 추가해놨습니다.
Then add this to your shell config (~/.bashrc, ~/.zshrc, ...):
export PATH="\$HOME/$filename/bin:\$PATH"
EOF

else
    echo "unknown os:$os_name"
fi
