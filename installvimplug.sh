#!/bin/bash

GOPATH=${HOME}/workspace/gopath
echo GOPATH=${GOPATH}

# GOPATH 디렉토리가 없다면 생성
mkdir -p ${GOPATH}

export GOPATH=${GOPATH}
export PATH=$PATH:$GOROOT:$GOPATH

# 다음 디렉토리가 없다면 생성
mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/bundle

# vim-plug 설치(플러그인 매니저중 플러그인 설치 속도가 가장 빠름)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# .vimrc 링크
[ -h ~/.vimrc ] && unlink ~/.vimrc
[ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
ln -s ${PWD}/.vimrc ~/.vimrc

# 플러그인 설치 vim 실행 후
# :PlugInstall
# :PlugUpdate
# 또는
# 터미널에서 플러그인 설치후 vim 종료
echo 'yes' | vim +PlugInstall +qall 2>/dev/null

# vim 실행 후 GoInstallBinaries 로 $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
# dockerfile 로 이미지 빌드시 사용자 입력을 받을 수 없으니 silent 모드로 설치
vim +'silent :GoInstallBinaries' +qall

# The ycmd server SHUT DOWN (restart with :YcmRestartServer) 메시지가 발생하는 경우
cd ~/.vim/plugged/youcompleteme/ && git submodule update --init --recursive && ./install.py --all --verbose

# FileNotFoundError: [Errno 2] No such file or directory: '/Users/ysoftman/.vim/plugged/youcompleteme/third_party/ycmd/third_party/go/bin/gopls' 에러 발생하는 경우
cd ~/.vim/plugged/youcompleteme/third_party/ycmd/ || exit
git checkout master
git pull
git submodule update --init --recursive
./build.py --go-completer --verbose

# YouCompleteMe unavailable: requires Vim compiled with Python (3.6.0+) support. 메시지가 발생하는 경우
# vim 에 +python3 로 설치되었는 확인 후 없으면(-python3) myenv/installvim.sh 로 소스빌드로 설치
vim --version | grep -i python
# 그래도 안되면, python3 으로 다시 YouCompleteMe 빌드
~/.vim/plugged/youcompleteme/install.py --all --verbose

# neovim 인 경우
# pip3 install pynvim
