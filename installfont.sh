#!/bin/bash
# mac 에선 installbrew.sh 에서 brew install font-fira-code font-hack-nerd-font 로 설치된다.

git clone https://github.com/powerline/fonts.git
cd fonts || exit
bash install.sh
cd ..
if [ -d ~/.termux ]; then
    cp -v fonts/Hack/Hack-Regular.ttf ~/.termux/font.ttf
fi
rm -rfv fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
if [ -d ~/.termux ]; then
    unzip Hack.zip -d ~/.termux
fi
rm -rf Hack.zip
