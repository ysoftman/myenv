#!/bin/bash
#export GOROOT=/usr/local/go
export GOPATH=$HOME/workspace/gopath
export PATH=/usr/local/bin:/usr/games:/usr/local/games:$GOPATH/bin:$PATH
# bash, zsh 등에서 git-subcommand 를 현재 디렉토리에서 실행하기 위해
# PATH 환경변수 처음이나 마지막에 구분자(:)가 있거나
# PATH 중간에 :: 부분이 있어야 한다.
# ./a.sh 대신 a.sh 실행 가능해야 한다.
export PATH=/usr/local/opt/openssl/bin:$PATH:
export EDITOR=vim
export VISUAL=vim
export ANSIBLE_NOCOWS=1 # disable cowsay message when using ansible

if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
    unalias ls
fi

if [[ $(uname) == 'Darwin' ]]; then
    export LSCOLORS='GxFxCxDxBxegedabagaced'
    export CLICOLOR=1
    alias ll='ls -ahlG'
    alias sn='pmset displaysleepnow'
elif [[ $(uname) == 'Linux' ]]; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
    #export PS1="\u@\h:\w\$ "
    export LS_COLORS='no=00:fi=00:di=00;36:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:ow=01;36;40:*.sh=00;32'
    alias ll='ls -ahl'
    # WSL(Windows Subsystem for Linux)
    if [[ $(uname -r | sed 's/-/ /g' | awk '{print $3}') == 'Microsoft' ]]; then
        alias netstat='/mnt/c/Windows/System32/netstat.exe'
    fi
fi

a=$(which colorls 2> /dev/null)
if [[ $? == 0 ]]; then
	alias ll='colorls -ahl'
fi

alias vi='vim'
alias vimlastfile='vim `(ls -1tr | tail -1)`'
alias gopath='cd $GOPATH'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'
alias cutstring='${HOME}/workspace/cutstring/cutstring'
alias enchash='${HOME}/workspace/enchash/enchash'
alias aleng='cd ~/workspace/aleng/ && ./aleng && cd -'
alias tig='tig --all'


a=$(which neofetch 2> /dev/null)
if [[ $? == 0 ]]; then
    if [[ $(uname) == 'Darwin' ]]; then
        neofetch --backend iterm2 --size 300 --source ${HOME}/xelloss.jpg
    else
        neofetch
    fi
else
    a=$(which screenfetch 2> /dev/null)
    if [[ $? == 0 ]]; then
        screenfetch -E
    fi
fi

# fortune + cowsay welcome message
msg="ysoftman"
a=$(which fortune 2> /dev/null)
if [[ $? == 0 ]]; then
    msg=$(fortune -s 2> /dev/null)
	if [[ $msg == '' ]]; then
		msg=$(fortune)
	fi
fi

a=$(which figlet 2> /dev/null)
if [[ $? == 0 ]]; then
    banner=$(figlet ysoftman 2> /dev/null)
    msg="${banner}\n${msg}"
fi

a=$(which cowsay 2> /dev/null)
if [[ $? == 0 ]]; then
    a=$(which lolcat 2> /dev/null)
    # figlet 을 메시지로 사용할 경우 -n 이 필요하다.
    if [[ $? == 0 ]]; then
        echo -e "$msg" | cowsay -n -f tux | lolcat
    else
        echo -e "$msg" | cowsay -n -f tux
    fi
fi

# prezto .zlogin fortune 을 실행하고 있어 .zlogin 에서 fortune 실행을 주석처리했다.
