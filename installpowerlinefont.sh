#!/bin/bash

git clone https://github.com/powerline/fonts.git
cd fonts || exit
bash install.sh
cd ..
if [ -d ~/.termux ]; then
    cp -v fonts/Hack/Hack-Regular.ttf ~/.termux/font.ttf
fi
rm -rfv fonts

# iterm2 -> preferences -> profiles -> text -> non-ascii font 에서 powerline 용 폰트 중 하나 선택
