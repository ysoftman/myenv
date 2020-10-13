#!/bin/bash
export GOPATH=$HOME/workspace/gopath
# bash, zsh 등에서 git-subcommand 를 현재 디렉토리에서 실행하기 위해
# PATH 환경변수 처음이나 마지막에 구분자(:)가 있거나
# PATH 중간에 :: 부분이 있어야 한다.
# ./a.sh 대신 a.sh 실행 가능해야 한다.
export PATH=/usr/local/bin:/usr/games:/usr/local/games:$GOPATH/bin:$PATH:

# 원래 맥에서 기본 제공하는 /usr/bin/ 의 curl 같은 프로그램은
# brew link --force 로도 /usr/local/bin/ 에 링크 생성을 못해
# PATH 환경변수에 /usr/local/opt/ 를 추가해야 한다.
export PATH=/usr/local/opt/curl-openssl/bin:$PATH
export PATH=/usr/local/opt/krb5/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH

export EDITOR=vim
export VISUAL=vim
export ANSIBLE_NOCOWS=1 # disable cowsay message when using ansible
# matplotlib on wsl
export DISPLAY=localhost:0.0

if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
    unalias ls
fi
temp=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $temp == 'darwin' ]]; then
    export LSCOLORS='GxFxCxDxBxegedabagaced'
    export CLICOLOR=1
    alias ll='ls -ahlG'
    alias sn='pmset displaysleepnow'
elif [[ $temp == 'linux' ]]; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
    #export PS1="\u@\h:\w\$ "
    export LS_COLORS='no=00:fi=00:di=00;36:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:ow=01;36;40:*.sh=00;32'
    alias ll='ls -ahl'
    # WSL(Windows Subsystem for Linux)
    temp=$(uname -r | awk '{print tolower($0)}')
    if [[ $temp == *"microsoft"* ]]; then
        # wsl.conf appendWindowsPath=false 인경우 vscode 경로 추가 필요
        export PATH=$PATH:"/mnt/c/Program Files/Microsoft VS Code/bin:"
        # 윈도우 netstat.exe 사용해야 실제 네트워크 상태를 알 수 있다.
        alias netstat='/mnt/c/Windows/System32/netstat.exe'
    fi
fi

temp=$(which colorls 2> /dev/null)
if [[ $? == 0 ]]; then
    alias ll='colorls -ahl'
fi
temp=$(which lsd 2> /dev/null)
if [[ $? == 0 ]]; then
    alias ll='lsd -ahl'
fi


# zsh 에서 rsync='noglob rsync' 등 glob(*)을 사용 못하게 alias 하고 있어 해제한다.
unalias bower 2> /dev/null
unalias fc 2> /dev/null
unalias find 2> /dev/null
unalias ftp 2> /dev/null
unalias globurl 2> /dev/null
unalias history 2> /dev/null
unalias locate 2> /dev/null
unalias rake 2> /dev/null
unalias rsync 2> /dev/null
unalias scp 2> /dev/null
unalias sftp 2> /dev/null

alias vi='vim'
alias vimlastfile='vim `(ls -1tr | tail -1)`'
alias gopath='cd $GOPATH'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'
alias cutstring='${HOME}/workspace/cutstring/cutstring'
alias enchash='${HOME}/workspace/enchash/enchash'
alias aleng='cd ~/workspace/aleng/ && ./aleng && cd -'
alias tig='tig --all'


# fzf ctrl+t(파일찾기)시
# 숨김파일도 보기
export FZF_CTRL_T_COMMAND='find . -type f'
temp=$(which fd 2> /dev/null)
if [ $? = 0 ] && [ -f $temp ]; then
    export FZF_CTRL_T_COMMAND='fd --hidden'
fi
# 파일내용 미리보기 창 설정
catcmd='cat {}'
temp=$(which bat 2> /dev/null)
if [ $? = 0 ] && [ -f $temp ]; then
    catcmd='bat --color always {}'
fi
export FZF_CTRL_T_OPTS="--preview '($catcmd || tree -C {}) 2> /dev/null | head -200'"


temp=$(which neofetch 2> /dev/null)
if [[ $? == 0 ]]; then
    if [[ $(uname -a | grep -i darwin) ]]; then
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
temp=$(which fortune 2> /dev/null)
if [[ $? == 0 ]]; then
    msg=$(fortune -s 2> /dev/null)
    if [[ $msg == '' ]]; then
        msg=$(fortune)
    fi
fi

temp=$(which figlet 2> /dev/null)
if [[ $? == 0 ]]; then
    banner=$(figlet ysoftman 2> /dev/null)
    msg="${banner}\n${msg}"
fi

temp=$(which cowsay 2> /dev/null)
if [[ $? == 0 ]]; then
    a=$(which lolcat 2> /dev/null)
    # figlet 을 메시지로 사용할 경우 -n 이 필요하다.
    if [[ $? == 0 ]]; then
        echo -e "$msg" | cowsay -n -f tux | lolcat
    else
        echo -e "$msg" | cowsay -n -f tux
    fi
fi
unset temp

# prezto .zlogin fortune 을 실행하고 있어 .zlogin 에서 fortune 실행을 주석처리했다.
