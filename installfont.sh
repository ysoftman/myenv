#!/bin/bash
os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

if [[ $os_name == *"darwin"* ]]; then
    # mac 에선 installbrew.sh 에서 brew install font-fira-code font-hack-nerd-font 로 설치된다.
    brew install font-fira-code font-hack-nerd-font
fi

# termux 에선 ~/.termux/font.ttf 파일만 폰트로 취급한다.
# termux-style 을 사용할 경우 폰트를 선택하면 ($PREFIX/share/termux-style/fonts/) -> ~/.termux/font.ttf 파일이 생긴다.
if [[ $os_name == *"android"* ]] && [ -d ~/.termux ]; then
    # hack v2.0 로 오래된 버전으로 glyph 가 다양하지 않아 사용하지 말자.
    # git clone https://github.com/powerline/fonts.git
    # cd fonts || exit
    # bash install.sh
    # cd ..
    # cp -v fonts/Hack/Hack-Regular.ttf ~/.termux/font.ttf
    # rm -rfv fonts

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    unzip Hack.zip -d hack_fonts
    cp -v hack_fonts/HackNerdFont-Regular.ttf ~/.termux/font.ttf
    rm -rf Hack.zip hack_fonts
fi
