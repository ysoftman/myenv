#!/bin/bash

git clone https://github.com/powerline/fonts.git
cd fonts
bash install.sh
cd ..
rm -rfv fonts

# iterm2 -> preferences -> profiles -> text -> non-ascii font 에서 powerline 용 폰트 중 하나 선택

