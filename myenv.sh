#!/bin/bash
#export GOROOT=/usr/local/go
export GOPATH=$HOME/workspace/gopath
export PATH=/usr/local/bin:$GOPATH/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH
export EDITOR=vim
export VISUAL=vim
export ANSIBLE_NOCOWS=1 # disable cowsay message when using ansible

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
    alias ll='ls -ahl --color=auto'
    # WSL(Windows Subsystem for Linux)
    if [[ $(uname -r | sed 's/-/ /g' | awk '{print $3}') == 'Microsoft' ]]; then
        alias netstat='/mnt/c/Windows/System32/netstat.exe'
    fi
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


# fortune + cowsay welcome message
msg="ysoftman"
a=$(which fortune 2> /dev/null)
if [[ $? == 0 ]]; then
    msg=$(fortune -s)
fi
a=$(which cowsay 2> /dev/null)
if [[ $? == 0 ]]; then
    echo "$msg" | cowsay -f tux
fi
# prezto .zlogin 을 사용할 경우 fortune 메시지가 한번 더 출력된다.
