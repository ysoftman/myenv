#!/bin/bash

git clone https://github.com/adi1090x/termux-style.git
cd termux-style
./install

cd ../
rm -rf termux-style

cat << zzz
# open termux style program to set colors, fonts, ...
termux-style
zzz
