#!/bin/bash
current_shell="bash"
if [[ $(ps -p $$ -o command | sed -e 1d) == *"bash" ]]; then
    current_shell="bash"
    shopt -s expand_aliases
elif [[ $(ps -p $$ -o command | sed -e 1d) == *"zsh" ]]; then
    current_shell="zsh"

    # mac builtin 설명 보기
    # bash 에서 help cd 로 설명을 볼 수 있다.
    # zsh 에서 builtin 설명을 보기 위해서 run-help=man alias 설정을 제거하고,
    # run-help 함수를 다시 로딩하면, run-help cd 로 설명을 볼 수 있다.
    unalias run-help 2> /dev/null
    autoload run-help

    if [[ $(uname -a | tr '[:upper:]' '[:lower:]') == *"android"* ]]; then
        # oh-my-zsh 사용
        source ~/.oh-my-zsh/templates/zshrc.zsh-template
    else
        # prezto 사용
        source ~/.zprezto/init.zsh
    fi

    # zsh-autosuggestions 사용
    if [ ! -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    fi
    if [ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
fi
# echo "current_shell=${current_shell}"


# set kubeconfig path
if [ -d ${HOME}/.kube ]; then
    export KUBECONFIG="${HOME}/.kube/config"
    for i in $(ls ${HOME}/.kube/*.yaml); do { KUBECONFIG+=":"$i; } done 2> /dev/null
    for i in $(ls ${HOME}/.kube/*.yml); do { KUBECONFIG+=":"$i; } done 2> /dev/null
    # KUBECONFIG 파일들 하나로 합칠때
    # kubectl config view --flatten > ${HOME}/.kube/z
fi

# kube prompt 사용 (brew install kube-ps1)
if [ -f "/usr/local/opt/kube-ps1/share/kube-ps1.sh" ]; then
    source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
    export KUBE_PS1_SYMBOL_USE_IMG=true
    # PS1='$(kube_ps1)'$'\n'$PS1  # 2 줄로 표시할때
    PS1='$(kube_ps1) '$PS1
fi

# fzf 가 설치되어 있다면 kubectx 실행시 fzf 선택 메뉴가 나타난다.
# fzf 메뉴 없이 kubectx 로 리스트만 보려면
# KUBECTX_IGNORE_FZF=1 kubectx
# 또는
# kubectx | cat

# install fzf
temp=$(type fzf 2> /dev/null)
if [[ $? != 0 ]]; then
    if [ ! -f ${HOME}/.fzf/bin/fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
    export PATH=$PATH:${HOME}/.fzf/bin
fi

# fzf default options
# --multi(-m) : tab(select/deselect forward) shift-tab(select/deselect backward)
export FZF_DEFAULT_OPTS='--multi --height 40% --layout=reverse --border --exact'
# fzf ctrl-t(파일찾기)시
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
    export BAT_THEME="TwoDark"
    catcmd='bat --color always {}'
fi
export FZF_CTRL_T_OPTS="--preview '($catcmd || tree -C {}) 2> /dev/null | head -200'"
# fzf ctrl-r(히스토리)시
export FZF_CTRL_R_OPTS=""

# $(brew --prefix)/opt/fzf/install 실행하면 .fzf.bash .fzf.zsh 파일이 생긴다.
# .bashrc .zshrc 에 맞게 다음이 자동으로 추가됨
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


export GOPATH=$HOME/workspace/gopath
# bash, zsh 등에서 git-subcommand 를 현재 디렉토리에서 실행하기 위해
# PATH 환경변수 처음이나 마지막에 구분자(:)가 있거나
# PATH 중간에 :: 부분이 있어야 한다.
# ./a.sh 대신 a.sh 실행 가능해야 한다.
export PATH=$HOME/.cargo/bin:/usr/local/go/bin/:/usr/local/bin:/usr/games:/usr/local/games:$GOPATH/bin:$PATH:

# 원래 맥에서 기본 제공하는 /usr/bin/ 의 curl 같은 프로그램은
# brew link --force 로도 /usr/local/bin/ 에 링크 생성을 못해
# PATH 환경변수에 /usr/local/opt/ 를 추가해야 한다.
export PATH=/usr/local/opt/curl-openssl/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH

export EDITOR=vim
export VISUAL=vim
export ANSIBLE_NOCOWS=1 # disable cowsay message when using ansible
# matplotlib on wsl
export DISPLAY=localhost:0.0

if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
    unalias ls 2> /dev/null
fi
temp=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $temp == *"darwin"* ]]; then
    export LSCOLORS='GxFxCxDxBxegedabagaced'
    export CLICOLOR=1
    alias ll='ls -ahlG'
    alias sn='pmset displaysleepnow'
elif [[ $temp == *"linux"* ]]; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
    #export PS1="\u@\h:\w\$ "
    export LS_COLORS='no=00:fi=00:di=00;36:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:ow=01;36;40:*.sh=00;32'
    alias ll='ls -ahl'
    # WSL(Windows Subsystem for Linux)
    temp=$(uname -r | awk '{print tolower($0)}')
    if [[ $temp == *"wsl"* ]]; then
        # wslvar reg.exe 에러 발생시 업데이트
        # sudo apt install wslu
        # wsl.conf appendWindowsPath=false 인경우 vscode 경로 추가 필요
        # export PATH=$PATH:"/mnt/c/Program Files/Microsoft VS Code/bin:"
        username=$(wslvar userprofile | tr '\\' ' ' | awk '{print $NF}')
        export PATH=$PATH:"/mnt/c/Users/${username}/AppData/Local/Programs/Microsoft VS Code/bin"
        # 윈도우 netstat.exe 사용해야 실제 네트워크 상태를 알 수 있다.
        alias netstat='/mnt/c/Windows/System32/netstat.exe'
    fi
fi

# replacement for ls
temp=$(which colorls 2> /dev/null)
if [[ $? == 0 ]]; then
    alias ll='colorls -ahl'
fi
temp=$(which exa 2> /dev/null)
if [[ $? == 0 ]]; then
    alias ll='exa -ahl'
fi
temp=$(which lsd 2> /dev/null)
if [[ $? == 0 ]]; then
    alias ll='lsd -ahl'
fi
# rg -p foo | less -R 와 같이 ansi color 유지해서 파이프라인으로 보낼때
if [ $(type rg 2> /dev/null | echo $?) = 0 ]; then
    alias rg='rg -p'
fi
# kubecolor (brew install hidetatz/tap/kubecolor)
# kubecolor internally calls kubectl command
if [ $(type kubecolor 2> /dev/null | echo $?) = 0 ]; then
    alias kubectl="kubecolor"
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
alias aleng='${HOME}/workspace/aleng/aleng'
alias tig='tig --all'
# cowsay 종류 계속 보이기
alias infinite_cowsay='for ((;;)); do for i in $(cowsay -l | sed 1d); do echo $i; cowsay -f $i $(fortune) | lolcat; sleep 0.2; done; done;'
# git issue script
alias python='python3'
alias gitissue='python3 ${HOME}/workspace/myenv/git_issue.py'
alias renamefiles="bash ${HOME}/workspace/myenv/renamefiles.sh"
# gh command - 깃헙 호스트별 최초 로그인 필요(gh auth login)
alias ghauthstatus='gh auth status'
alias ghissueme='gh issue list --assignee @me'
alias ghissueview='gh issue view' # 뒤에 이슈번호 아규먼트 명시


temp=$(which pyenv 2> /dev/null)
if [[ $? == 0 ]]; then
    eval "$(pyenv init -)"
fi
temp=$(which virtualenv 2> /dev/null)
if [[ $? == 0 ]]; then
    eval "$(pyenv virtualenv-init -)"
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
fi

temp=$(which neofetch 2> /dev/null)
if [[ $? == 0 ]]; then
    term_program=$(echo $TERM_PROGRAM | tr "[:upper:]" "[:lower:]")
    if [[ $term_program == *"iterm"* ]]; then
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
    # cowfile 랜덤으로 선택
    cowfile=""
    cnt=0
    random=$(( RANDOM % $(cowsay -l | sed 1d | wc -w ) ))
    # echo $random
    for i in $(cowsay -l | sed 1d); do
        if [[ $cnt == $random ]]; then
            cowfile=$i;
            break;
        fi;
        cnt=$(( cnt+1 ));
    done
    echo $cowfile


    a=$(which lolcat 2> /dev/null)
    # figlet 을 메시지로 사용할 경우 -n 이 필요하다.
    if [[ $? == 0 ]]; then
        echo -e "$msg" | cowsay -n -f $cowfile | lolcat
    else
        echo -e "$msg" | cowsay -n -f $cowfile
    fi
fi
unset temp

# prezto .zlogin fortune 을 실행하고 있어 .zlogin 에서 fortune 실행을 주석처리했다.
