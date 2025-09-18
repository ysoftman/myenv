#!/bin/bash

# termux 설정 파일 링크
ln -sfv ${PWD}/termux.properties ~/.termux/termux.properties

# storage 마운트 설정
# 다음 명령을 실행하면 ~/storage 위치에 폰 스토리지가 마운트 된다.
# 참고로 이 명령은 termux 설치 후 1번만 수행하면 된다.
termux-setup-storage

# termux-style 설치
git clone https://github.com/adi1090x/termux-style.git
cd termux-style || exit
./install

cd ../
rm -rf termux-style

cat <<zzz
# termux-style 명령을 실행해 컬러를 설정하자.
# termux-style 로 font 설정시 제공하는 폰트에 glyph 문자가 없어 깨져 보인다.
# font 는 bash ./installfont.sh 로 최신 Hack 폰트를 설치해서 사용하자.
zzz
