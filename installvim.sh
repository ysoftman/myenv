#!/bin/bash
# ysoftman
# vim 설치 스크립트


reinstallarg=""
if (($# >= 1)); then
	if [[ $1 == 'reinstall' ]]; then
		reinstallarg=$1
		echo $reinstallarg
	else
		echo '[if you want to reinstall vim] bash' $0 reinstall
		exit 1
	fi
fi

# go, ruby, mercurial, python, cmake, ctags 설치 및 환경변수 설정
if [ $(uname) == 'Darwin' ]; then
	echo 'OSX Environment'
	brew install go
	export GOROOT=/usr/local/bin/go
	brew install ruby lua mercurial python cmake ctags python3 tig vim
elif [ $(uname) == 'Linux' ]; then
	echo 'Linux Environment'
	# yum 실행보기
	yum --version
	# yum 실행후 exit code 0(SUCCESS) 이라면 사용할수 있다.
	if [ $? == 0 ]; then
		package_program="yum -y"
	else
		package_program="apt-get"
	fi
	sudo ${package_program} install gcc-c++ wget go vim
	export GOROOT=/usr/bin/go
	sudo ${package_program} install ruby lua5.3 mercurial python-dev cmake ctags python34-devel tig
else
	echo 'Only OS-X or Linux... exit'
	# 소스 빌드 및 설치
	#wget https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz
	#tar -zxvf go1.4.linux-amd64.tar.gz
	#echo 'build and install golang'
	#export GOROOT=$PATH:$HOME/gGo
	exit
fi

installvim() {
	# 최신 버전 vim 설치
	if [ ! -d 'vim-8.0.1432' ]; then
		# git clone https://github.com/vim/vim.git
		wget "https://github.com/vim/vim/archive/v8.0.1432.tar.gz"
		tar zxvf v8.0.1432.tar.gz
	fi
	cd vim-8.0.1432/src
	make distclean
	# youcompleteme 플러그인이 python 을 사용하기때문에  python2,3 을 지원하는 vim 으로 빌드되어야 한다.
	# ruby, lua 지원도 포함해두자
	./configure --enable-pythoninterp=yes --enable-python3interp=yes --enable-rubyinterp=yes --enable-luainterp=yes
	make -j 8
	sudo make install
}

# 설치된 vim 버전이 너무 낮으면 소스 받아서 설치
base_vim_version="8.0"
cur_vim_version=$(vim --version | grep 'Vi IMproved' | awk '{print $5}')
echo "cur_vim_version : ${cur_vim_version}"
highest_version="$(printf "${cur_vim_version}\n${base_vim_version}" | sort -r | head -n1)"
if [ ${highest_version} != ${cur_vim_version} ]; then
	echo "cur_vim_version < ${base_vim_version}"
	echo "installvim()..."
	installvim
else
	echo "cur_vim_version >= ${base_vim_version}"
fi

# 강제 재설치하는 경우
if [[ ${reinstallarg} == "reinstall" ]]; then
	echo "installvim()..."
	installvim
fi


GOPATH=${HOME}/workspace/gopath
echo GOPATH=${GOPATH}

# GOPATH 디렉토리가 없다면 생성
mkdir -p ${GOPATH}

export GOPATH=${GOPATH}
export PATH=$PATH:$GOROOT:$GOPATH

# 다음 디렉토리가 없다면 생성
mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/bundle
