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
    cd vim-${base_vim_version}/src || return
    make distclean
    # youcompleteme 플러그인이 python 을 사용하기때문에  python2,3 을 지원하는 vim 으로 빌드되어야 한다.
    # ruby, lua 지원도 포함해두자
    ./configure --enable-pythoninterp=yes --enable-python3interp=yes --enable-rubyinterp=yes --enable-luainterp=yes
    make -j 8
    sudo make install
}

if (($# >= 1)); then
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
if [[ $(uname -o 2>/dev/null) == 'Android' ]]; then
    pkg update
    pkg upgrade
    # vim, vim-python 한번에 설치시 의존성 에러 발생해 별도 설치
    pkg install -y vim
    pkg install -y vim-python
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
    ret=$?
    # yum 실행후 exit code 0(SUCCESS) 이라면 사용할수 있다.
    if [[ $ret == 0 ]]; then
        package_program="yum"
    else
        package_program="apt"
        # sudo apt update
    fi
    sudo ${package_program} install -y gcc g++ gcc-c++ wget go vim ncurses-devel
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
cur_vim_patch_version=$(vim --version | grep 'Included patches' | awk '{print $3}' | sed 's/^.*-//')
cur_vim_version=$(vim --version | grep 'Vi IMproved' | awk '{print $5}')
cur_vim_version+=".$cur_vim_patch_version"
echo "cur_vim_version : ${cur_vim_version}"
highest_version="$(echo -e "${cur_vim_version}\n${base_vim_version}" | sort -r | head -n1)"
if [[ ${highest_version} != "${cur_vim_version}" ]]; then
    echo "cur_vim_version < ${base_vim_version}"
    echo "install_vim_from_src()..."
    install_vim_from_src
else
    echo "cur_vim_version >= ${base_vim_version}"
fi
