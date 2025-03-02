#!/bin/bash

if command -v nvim >/dev/null; then
    echo "nvim(neovim) already exists."
    exit
fi

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install neovim
    exit
elif [[ $os_name == *"linux"* ]]; then
    echo "download neovim latest version"
    filename="nvim-linux-x86_64"
    url="https://github.com/neovim/neovim-releases/releases/download/v0.10.4/$filename.appimage"
    curl -LO $url
    tar -C $HOME/ -xzf $filename.tar.gz

    chmod +x $HOME/$filename/bin/nvim.appimage
    cat <<EOF
myenv.sh 에서 추가해놨습니다.
Then add this to your shell config (~/.bashrc, ~/.zshrc, ...):
export PATH="\$HOME/$filename/bin:\$PATH"

# 실행
nvim.appimage
EOF

else
    echo "unknown os:$os_name"
fi
