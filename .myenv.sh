#!/bin/bash
export LSCOLORS=GxFxCxDxBxegedabagaced
export CLICOLOR=1
export GOPATH=$HOME/workspace/gopath
export PATH=$PATH:$HOME:$GOPATH/bin:
export PATH=$PATH:/usr/local/opt/openssl/bin:

export PYTHONPATH=/Library/Python/2.7/site-packages
#export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.6/site-packages
export EDITOR=vim
export VISUAL=vim

if [[ $(uname) == 'Linux' ]]; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
fi

alias vi='vim'
alias ll='ls -ahlG'
alias gopath='cd $GOPATH'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'
alias cutstring='${HOME}/workspace/cutstring/cutstring'
alias enchash='${HOME}/workspace/enchash/enchash'
alias aleng='cd ~/workspace/aleng/ && aleng && cd -'

# for osx
alias sn='pmset displaysleepnow'
