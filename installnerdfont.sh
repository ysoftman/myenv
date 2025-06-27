#!/bin/bash
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
# for termux
if [ -d ~/.termux ]; then
    unzip Hack.zip -d ~/.termux
fi

# mac
if [ -d ~/Library/Fonts ]; then
    unzip Hack.zip -d ~/Library/Fonts
fi

rm -rf Hack.zip
