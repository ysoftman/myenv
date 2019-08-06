#!/bin/bash
common_pkgs='zsh vim curl git tig tmux cmake ctags fortune cowsay figlet cmatrix python python-dev ruby golang man dnsutils gem'
sudo_cmd='sudo'

if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
	sudo_cmd=''
	package_program="apt"
	${sudo_cmd} ${package_program} update
	${sudo_cmd} ${package_program} upgrade
	${sudo_cmd} ${package_program} install -y ${common_pkgs} python2 python2-dev ripgrep fzf  lua openssh libandroid-support
	chsh -s zsh
	${sudo_cmd} ${package_program} install -y vim-python
	gem install lolcat
	exit 0
elif [[ $(uname) == 'Darwin' ]]; then
	echo 'OSX Environment'
	# brew 설치
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	# zsh 설치
	brew install zsh
	# pip 설치
	${sudo_cmd} easy_install pip
	${sudo_cmd} gem install colorls
elif [[ $(uname) == 'Linux' ]]; then
	echo 'Linux Environment'
	# yum 실행보기
	yum --version
	# yum 실행후 exit code 0(SUCCESS) 이라면 사용할수 있다.
	if [ $? == 0 ]; then
		package_program="yum"
	else
		package_program="apt-get"
	fi
	${sudo_cmd} ${package_program} update
	# centos, ubuntu 모두 있음
	${sudo_cmd} ${package_program} install -y ${common_pkgs} python-pip clang-format
	if [[ package_program="yum" ]]; then
		# ncurses - yum 에서 설치
		${sudo_cmd} ${package_program} install -y ncurses ncurses-devel
	elif [[ package_program="apt-get" ]]; then
		# ncurses - ubuntu 에서 설치
		${sudo_cmd} ${package_program} install -y build-essential libncurses5-dev
	fi
	# export LC_ALL=ko_KR.utf8 사용을 위해서 정의되어 있어야 한다.
	${sudo_cmd} localedef -f UTF-8 -i ko_KR ko_KR.utf8
	gem install colorls

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
		./configure && make -j 4 && ${sudo_cmd} make install
		/usr/local/bin/zsh --version
	else
		echo "${compare_version} < ${cur_version}"
	fi
else
	echo 'This OS is not (Android or OS-X or Linux)'
	exit 1
fi

# 현재 유저의 기본 쉘을 zsh 로 변경
cat /etc/shells > shells
zsh_path=`cat shells | grep /usr/local/bin/zsh`
echo $zsh_path
# null string 이라면
if [ -z ${zsh_path} ]; then
	# /etc/shells 는 >> 를 허용하지 않아 수정 파일로 바꿔친다.
	echo "/usr/local/bin/zsh" >> shells
	${sudo_cmd} mv -v shells /etc/shells
fi
rm -fv shells
${sudo_cmd} cp -fv chsh /etc/pam.d/chsh
if  [ -x /usr/local/bin/zsh ]; then
	${sudo_cmd} chsh -s /usr/local/bin/zsh ${USER}
elif [ -x /usr/bin/zsh ]; then
	${sudo_cmd} chsh -s /usr/bin/zsh ${USER}
elif [ -x /bin/zsh ]; then
	${sudo_cmd} chsh -s /bin/zsh ${USER}
else
	echo 'can not find zsh'
fi
