#!/bin/bash
export GOPATH=$HOME/workspace/gopath
export PATH=$PATH:$HOME:$GOPATH/bin:
export PATH=$PATH:/usr/local/opt/openssl/bin:
export EDITOR=vim
export VISUAL=vim

if [[ $(uname) == 'Darwin' ]]; then
    export LSCOLORS='GxFxCxDxBxegedabagaced'
    export CLICOLOR=1
    alias ll='ls -ahlG'
    alias sn='pmset displaysleepnow'
elif [[ $(uname) == 'Linux' ]]; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
    export PS1="\u@\h:\w\$ "
    export LS_COLORS='no=00:fi=00:di=00;36:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:*.sh=00;32:'
    alias ll='ls -ahl --color=auto'
fi

alias vi='vim'
alias gopath='cd $GOPATH'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'
alias cutstring='${HOME}/workspace/cutstring/cutstring'
alias enchash='${HOME}/workspace/enchash/enchash'
alias aleng='cd ~/workspace/aleng/ && aleng && cd -'
