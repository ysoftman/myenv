#!/bin/bash

# zsh pip brew ruby .. 기본 프로그램 설치
if [ $(uname) == 'Darwin' ]; then
	echo 'OSX Environment'
	# brew 설치
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	# zsh , pyenv 설치
	brew install zsh pyenv
	# pip 설치
	sudo easy_install pip
	pyenv install -f 2.7.14
	pyenv install -f 3.6.4
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
	echo "package_program ${package_program}"
	# centos, ubuntu 모두 있음
	sudo ${package_program} install zsh python-pip ruby
	# ncurses - yum 에서 설치
	sudo ${package_program} install ncurses ncurses-devel
	# ncurses - ubuntu 에서 설치
	sudo ${package_program} install build-essential libncurses5-dev

	# zsh 버전이 낮으면 소스 다운로드 받아 설치하기
	cur_version="$(zsh --version | cut -d" " -f2)"
	compare_version="5.1.999"
	echo 'cur_version='${cur_version}
	echo 'compare_version='${compare_version}
	highest_version="$(printf "${cur_version}\n${compare_version}" | sort -r | head -n1)"
	echo 'highest_version='${highest_version}
	if [ "${highest_version}" == "${compare_version}" ]; then
		echo "${compare_version} > ${cur_version}"
		curl -OL https://sourceforge.net/projects/zsh/files/zsh/5.2/zsh-5.2.tar.gz/download
		mv download zsh-5.2.tar.gz
		tar zxvf zsh-5.2.tar.gz
		cd zsh-5.2
		./configure && make -j 4 && sudo make install
		/usr/local/bin/zsh --version
	else
		echo "${compare_version} < ${cur_version}"
	fi

else
	echo 'Only OS-X or Linux... exit'
	exit
fi

# 현재 유저의 기본 쉘을 zsh 로 변경
cat /etc/shells > shells
zsh_path=`cat shells | grep /usr/local/bin/zsh`
echo $zsh_path
# null string 이라면
if [ -z ${zsh_path} ]; then
	# /etc/shells 는 >> 를 허용하지 않아 수정 파일로 바꿔친다.
	echo "/usr/local/bin/zsh" >> shells
	sudo mv -v shells /etc/shells
fi
rm -fv shells
sudo chsh -s /usr/local/bin/zsh ${USER}
