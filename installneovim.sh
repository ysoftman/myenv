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
export PATH="\$HOME/$filename/bin:\$PATH"

#####

# glibc 2.29 미만(ldd --version 확인) 환경에서는
# glibc, gcc 설치
bash installglibc.sh
bash installgcc.sh
cp -v ~/gcc-14.2.0/lib64/libgcc_s.so.1  ~/glibc-2.41/build/lib

# nvim elf 동적라이브러리 경로 수정
sudo dnf install patchelf
patchelf --set-rpath ~/glibc-2.41/build/lib ~/nvim-linux-x86_64/bin/nvim
patchelf --set-interpreter ~/glibc-2.41/build/lib/ld-linux-x86-64.so.2 ~/nvim-linux-x86_64/bin/nvim
EOF

else
    echo "unknown os:$os_name"
fi
