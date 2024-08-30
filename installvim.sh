#!/bin/bash
# ysoftman
# vim 설치 스크립트

base_vim_version="9.1.0"
install_vim_from_src() {
    # 최신 버전 vim 설치
    if [ ! -d "vim-${base_vim_version}" ]; then
        # git clone https://github.com/vim/vim.git
        wget "https://github.com/vim/vim/archive/v${base_vim_version}.tar.gz"
        tar zxvf v${base_vim_version}.tar.gz
    fi
    cd vim-${base_vim_version}/src
    make distclean
    # youcompleteme 플러그인이 python 을 사용하기때문에  python2,3 을 지원하는 vim 으로 빌드되어야 한다.
    # ruby, lua 지원도 포함해두자
    ./configure --enable-pythoninterp=yes --enable-python3interp=yes --enable-rubyinterp=yes --enable-luainterp=yes
    make -j 8
    sudo make install
}

install_vim_plugin() {
    GOPATH=${HOME}/workspace/gopath
    echo GOPATH=${GOPATH}

    # GOPATH 디렉토리가 없다면 생성
    mkdir -p ${GOPATH}

    export GOPATH=${GOPATH}
    export PATH=$PATH:$GOROOT:$GOPATH

    # 다음 디렉토리가 없다면 생성
    mkdir -p ~/.vim/autoload
    mkdir -p ~/.vim/bundle

    # 패키지 관리를 위한 Plug 설치
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # .vimrc 링크
    [ -h ~/.vimrc ] && unlink ~/.vimrc
    [ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
    ln -s ${PWD}/.vimrc ~/.vimrc

    # 터미널에서 플러그인 설치후 vim 종료
    echo 'yes' | vim +PlugInstall +qall 2> /dev/null

    # vim 실행 후 GoInstallBinaries 로 $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
    # dockerfile 로 이미지 빌드시 사용자 입력을 받을 수 없으니 silent 모드로 설치
    vim +'silent :GoInstallBinaries' +qall

    # The ycmd server SHUT DOWN (restart with :YcmRestartServer) 메시지가 발생하는 경우
    cd ~/.vim/plugged/youcompleteme/ && git submodule update --init --recursive
    ./install.py --verbose

    # FileNotFoundError: [Errno 2] No such file or directory: '/Users/ysoftman/.vim/plugged/youcompleteme/third_party/ycmd/third_party/go/bin/gopls' 에러 발생하는 경우
    cd ~/.vim/plugged/youcompleteme/third_party/ycmd/
    git checkout master
    git pull
    git submodule update --init --recursive
    ./build.py --go-completer --verbose
}

if (( $# >= 1 )); then
    # 강제 재설치하는 경우
    if [[ $1 == 'install_from_src' ]]; then
        echo "install_vim_from_src()..."
        install_vim_from_src
        exit 0
    else
        echo '[if you want to install_from_src vim] bash' $0 install_from_src
        exit 1
    fi
fi

# go, ruby, mercurial, python, cmake, ctags 설치 및 환경변수 설정
if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
    pkg update
    pkg upgrade
    # vim, vim-python 한번에 설치시 의존성 에러 발생해 별도 설치
    pkg install -y vim
    pkg install -y vim-python
    install_vim_plugin
    exit 0
elif [[ $(uname) == 'Darwin' ]]; then
    echo 'OSX Environment'
    brew install go
    export GOROOT=/usr/local/bin/go
    brew install ruby lua mercurial python cmake ctags python3 tig vim
elif [[ $(uname) == 'Linux' ]]; then
    echo 'Linux Environment'
    # yum 실행보기
    yum --version
    # yum 실행후 exit code 0(SUCCESS) 이라면 사용할수 있다.
    if [[ $? == 0 ]]; then
        package_program="yum"
    else
        package_program="apt"
        # sudo apt update
    fi
    sudo ${package_program} install -y gcc g++ gcc-c++ wget go vim
    export GOROOT=/usr/bin/go
    sudo ${package_program} install -y ruby lua5.3 mercurial python-dev cmake ctags python34-devel tig
else
    echo 'Only OS-X or Linux... exit'
    # 소스 빌드 및 설치
    #wget https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz
    #tar -zxvf go1.4.linux-amd64.tar.gz
    #echo 'build and install golang'
    #export GOROOT=$PATH:$HOME/gGo
    exit
fi

# 설치된 vim 버전이 너무 낮으면 소스 받아서 설치
cur_vim_version=$(vim --version | grep 'Vi IMproved' | awk '{print $5}')
echo "cur_vim_version : ${cur_vim_version}"
highest_version="$(printf "${cur_vim_version}\n${base_vim_version}" | sort -r | head -n1)"
if [[ ${highest_version} != ${cur_vim_version} ]]; then
    echo "cur_vim_version < ${base_vim_version}"
    echo "install_vim_from_src()..."
    install_vim_from_src
else
    echo "cur_vim_version >= ${base_vim_version}"
fi

install_vim_plugin
