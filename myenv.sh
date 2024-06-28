#!/bin/bash
# /etc/profile -> /usr/libexec/path_helper -> /etc/paths 까지 설정 확인시
#echo $PATH | tr ':' '\n'

export myenv_path=$(dirname $0)
export PATH=$myenv_path:$PATH
echo "myenv_path=$myenv_path"

source ${myenv_path}/colors.sh

current_shell="bash"
if [[ $(ps -p $$ -o command | sed -e 1d) == *"bash"* ]]; then
    current_shell="bash"
    shopt -s expand_aliases
elif [[ $(ps -p $$ -o command | sed -e 1d) == *"zsh"* ]]; then
    current_shell="zsh"

    # mac builtin 설명 보기
    # bash 에서 help cd 로 설명을 볼 수 있다.
    # zsh 에서 builtin 설명을 보기 위해서 run-help=man alias 설정을 제거하고,
    # run-help 함수를 다시 로딩하면, run-help cd 로 설명을 볼 수 있다.
    unalias run-help 2> /dev/null
    autoload run-help

    if [[ $(uname -a | tr '[:upper:]' '[:lower:]') == *"android"* ]]; then
        # termux 에서 prezto 사용시 pmodload: no such module: prompt git ... 등 모듈로딩 에러 발생
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

# set XDG_CONFIG_HOME
export XDG_CONFIG_HOME="$HOME/.config"

# set kubeconfig path
if [ -d ${HOME}/.kube ]; then
    export KUBECONFIG="${HOME}/.kube/config"
    for i in $(ls ${HOME}/.kube/*.yaml); do
        KUBECONFIG+=":"$i;
    done 2> /dev/null
    for i in $(ls ${HOME}/.kube/*.yml); do
        KUBECONFIG+=":"$i;
    done 2> /dev/null
    # KUBECONFIG 파일들 하나로 합칠때
    # kubectl config view --flatten > ${HOME}/.kube/z
fi

# kube prompt 사용
# brew install kube-ps1 로 설치시 최신 버전아님
#kube_ps1_path="/usr/local/opt/kube-ps1/share/kube-ps1.sh"
kube_ps1_path="${myenv_path}/kube-ps1.sh"
if [ -f ${kube_ps1_path} ]; then
    source ${kube_ps1_path}
    export KUBE_PS1_SYMBOL_USE_IMG=true
    # PS1='$(kube_ps1)'$'\n'$PS1  # 2 줄로 표시할때
    PS1='$(kube_ps1) '$PS1
    # kube-ps1 off/on command(function in script)
    # kubeoff -g
    # kubeon -g
fi

# fzf 가 설치되어 있다면 kubectx 실행시 fzf 선택 메뉴가 나타난다.
# fzf 메뉴 없이 kubectx 로 리스트만 보려면
# KUBECTX_IGNORE_FZF=1 kubectx
# 또는
# kubectx | cat

# install fzf
if type fzf > /dev/null 2>&1; then
    if [ ! -f ${HOME}/.fzf/bin/fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
    export PATH=$PATH:${HOME}/.fzf/bin
fi

## fzf default options
# --multi(-m) : tab(select/deselect forward) shift-tab(select/deselect backward)
# https://github.com/junegunn/fzf/wiki/Color-schemes
export FZF_DEFAULT_OPTS='--multi --height 40% --layout=reverse --border --exact
--color=dark
--color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
--color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
'
# zellij 에서 ctrl-t 가 tab 명령 단축키라 FZF_CTRL_T_COMMAND(ctrl-t)와 중복된다.
# alt-t 로도 FZF_CTRL_T_COMMAND(fzf-file-widget) 사용할 수 있도록 등록한다.
if [[ $current_shell == "zsh" ]]; then
    bindkey "^[t" fzf-file-widget
    source ${myenv_path}/fzf-git.sh
    # fzf-git.sh 에선 ctrl-g ctrl-b 로 사용하는데, zellij 와 중복되어 alt-b 로도 바인딩함
    # alt-b 는 alt-left(showkey 로 확인)라 alt-B 로 사용하자
    #bindkey "^[b" "fzf-git-branches-widget"
    bindkey "^[B" "fzf-git-branches-widget"
fi
# fzf ctrl-t(파일찾기)시
# 숨김파일도 보기
export FZF_CTRL_T_COMMAND='find . -type f'
if which fd > /dev/null 2>&1; then
    export FZF_CTRL_T_COMMAND='fd --hidden --no-ignore'
fi
# fzf vim 에서 FZF_DEFAULT_COMMAND 를 사용함
export FZF_DEFAULT_COMMAND=$FZF_CTRL_T_COMMAND

# fzf preview window
catcmd='cat {}'
if which bat > /dev/null 2>&1; then
    export BAT_THEME="TwoDark"  # vim fzf preview
    batcmd="bat --plain --color always"
    catcmd="${batcmd} {}"
    alias bat="${batcmd}"
fi
export FZF_CTRL_T_OPTS="--preview '($catcmd || tree -C {}) 2> /dev/null | head -200'"
# fzf ctrl-r(히스토리)시
export FZF_CTRL_R_OPTS=""

# $(brew --prefix)/opt/fzf/install 실행하면 .fzf.bash .fzf.zsh 파일이 생긴다.
# .bashrc .zshrc 에 맞게 다음이 자동으로 추가됨
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export GOPATH=$HOME/workspace/gopath
tidy_path() {
    local temp_path=""
    for p in $(echo $PATH | tr : '\n' | uniq); do
        if [[ $p == '/opt/homebrew/bin' ]]; then
            continue
        elif [[ $p == '/usr/local/bin' ]]; then
            continue
        elif [[ $p == "${HOME}/.cargo/bin" ]]; then
            continue
        elif [[ $p == "${GOPATH}" ]]; then
            continue
        fi
        if [[ $temp_path == '' ]]; then
            temp_path=$p
            continue
        fi
        temp_path=$temp_path:$p
    done
    # bash, zsh 등에서 git-subcommand 를 현재 디렉토리에서 실행하기 위해
    # PATH 환경변수 처음이나 마지막에 구분자(:)가 있거나
    # PATH 중간에 :: 부분이 있어야 한다.
    # ./a.sh 대신 a.sh 실행 가능해야 한다.
    # apple silicon 용 brew (/opt/homebrew) 를 우선 실행할 수 있도록 한다.
    export PATH=$HOME/.cargo/bin:$GOPATH/bin:/opt/homebrew/bin:/opt/homebrew/opt/curl/bin:/usr/local/bin::$temp_path
}
tidy_path

export EDITOR=vim
export VISUAL=vim
export ANSIBLE_NOCOWS=1 # disable cowsay message when using ansible
# matplotlib on wsl
export DISPLAY=localhost:0.0

if [[ $(uname -o 2> /dev/null) == 'Android' ]]; then
    unalias ls 2> /dev/null
fi
os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    export LSCOLORS='GxFxCxDxBxegedabagaced'
    export CLICOLOR=1
    alias ll='ls -ahlG'
    alias sn='pmset displaysleepnow'
elif [[ $os_name == *"linux"* ]]; then
    if [[ $(uname -a | tr '[:upper:]' '[:lower:]') == *"android"* ]]; then
        # termux 는 현재 영어만 지원하고 있다.
        # https://github.com/termux/termux-packages/issues/2796#issuecomment-424589888
        export LANG=en_US.UTF-8
    else
        export LANG=ko_KR.utf8
        export LC_ALL=ko_KR.utf8
    fi
    #export PS1="\u@\h:\w\$ "
    export LS_COLORS='no=00:fi=00:di=00;36:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:ow=01;36;40:*.sh=00;32'
    alias ll='ls -ahl'
    # WSL(Windows Subsystem for Linux)
    os_name=$(uname -r | awk '{print tolower($0)}')
    if [[ $os_name == *"wsl"* ]]; then
        os_name=$(wslvar userprofile 2> /dev/null)
        if [ $? != 0 ]; then
            # wslvar reg.exe 등의 에러 발생시 업데이트
            echo "need to install wslu for wslvar(reg.exe...)"
            sudo apt install -y wslu
        fi
        # wsl.conf appendWindowsPath=false 인경우 vscode 경로 추가 필요
        # export PATH=$PATH:"/mnt/c/Program Files/Microsoft VS Code/bin:"
        username=$(wslvar userprofile | tr '\\' ' ' | awk '{print $NF}')
        export PATH=$PATH:"/mnt/c/Users/${username}/AppData/Local/Programs/Microsoft VS Code/bin"
        # 윈도우 netstat.exe 사용해야 실제 네트워크 상태를 알 수 있다.
        alias netstat='/mnt/c/Windows/System32/netstat.exe'
        # wsl+terminal 앱에서 less(git diff, man ls...)페이지 처음/끝에서 더 이동시 beep 발생 방지를 위해 기존 옵션에 -R -Q 을 추가해야 한다.
        export LESS="$LESS -R -Q"
    fi
fi

# replacement for ls
if which colorls > /dev/null 2>&1; then
    alias ll='colorls -ahl'
fi
if which exa > /dev/null 2>&1; then
    alias ll='exa -ahl'
fi
if which lsd > /dev/null 2>&1; then
    alias ll='lsd -ahl'
fi
# Phase foo | less -R 와 같이 ansi color 유지해서 파이프라인으로 보낼때
# redirection, pipe 등에서 컬러 값이 포함돼 에러가 발생해서 사용하지 않음.
# -p, --pretty (--color=always --heading --line-number)
# --color=auto (default), redirection, pip --> suppress color
#if type rg > /dev/null 2>&1; then
#    alias rg='rg -p'
#fi

# zsh 환경에서 kubectl 자동 완성
source <(kubectl completion zsh)
# kubecolor (brew install hidetatz/tap/kubecolor)
# kubecolor internally calls kubectl command
if type kubecolor > /dev/null 2>&1; then
    alias kubectl='kubecolor'
    # kubecolor 로 kubectl 자동 완성
    compdef kubecolor=kubectl
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
#ymcd 가 nvim 공식 지원안함
#alias vi='nvim'
alias vimlastfile='vim `(ls -1tr | tail -1)`'
alias gopath='cd $GOPATH'
alias myenv='cd ${myenv_path}'
alias work='cd ${HOME}/workspace'
alias testcode='cd ${HOME}/workspace/test_code'
alias cutstring='${HOME}/workspace/cutstring/cutstring'
alias enchash='${HOME}/workspace/enchash/enchash'
alias aleng='${HOME}/workspace/aleng/aleng'
alias tig='tig --all'
# cowsay 종류 계속 보이기
alias infinite_cowsay='for ((;;)); do for i in $(cowsay -l | sed 1d); do echo $i; cowsay -f $i $(fortune) | lolcat; sleep 0.2; done; done;'
# git issue script --> gh(github) command 로 대체해서 사용하지 않음
#alias gitissue="python3 ${myenv_path}/git_issue.py"
#alias gitpj="python3 ${myenv_path}/git_project.py"
# gh command - 깃헙 호스트별 최초 로그인 필요(gh auth login)
alias ghauthstatus='gh auth status'
alias ghissueme='gh issue list --assignee @me'
alias ghissueview='gh issue view' # 뒤에 이슈번호 아규먼트 명시
alias k='kubectl'
alias m-c='/usr/local/Cellar/midnight-commander/4.8.28/bin/mc'
# 현재 하위 모든 git 디렉토리 pull 받기
alias gitpullall='for dir in $(fd -H -d 2 ".git$" | awk -F "/.git.*$" "{print \$1}"); do
printf "${green}[%s]==> $reset_color" "$dir"; git -C $dir pull;
done'
alias duf="duf -theme dark"
# ssh 원격 접속시 clear 실행하면 'alacritty': unknown terminal type. 메시지 발생 방지
alias ssh='TERM=xterm-256color ssh'

# apple silicon(arm64)용으로 zsh 실행
alias arm='arch -arm64 /bin/zsh'

# load my functions
source ${myenv_path}/rename_files.sh
source ${myenv_path}/cnt_src.sh
source ${myenv_path}/git_functions.sh
source ${myenv_path}/k8s_info.sh

if which pyenv > /dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
if which virtualenv > /dev/null 2>&1; then
    # precmd_function 에 _pyenv_virtualenv_hook() 를 추가 시키고
    # 이 함수는 pyenv sh-activate 를 실행하는게 이게 느림(400ms 정도)
    # pyenv sh-activate 내용 https://github.com/pyenv/pyenv-virtualenv/blob/master/bin/pyenv-sh-activate
    # prompt 속도가 느려지니 필요없으면 제외시키자.
    #eval "$(pyenv virtualenv-init -)"
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
fi

if [[ $TERM == *"alacritty"* ]]; then
    export TERM=xterm-256color
    # musikcube 등 실행시 terminfo 필요
    if [[ $os_name == *"darwin"* ]]; then
        export TERMINFO=/opt/homebrew/opt/ncurses/share/terminfo
    fi
fi

term_program=$(echo $TERM_PROGRAM | tr "[:upper:]" "[:lower:]")

if which fastfetch > /dev/null 2>&1; then
    args="--cpu-temp true --gpu-temp true"
    if [[ $term_program == *"iterm"* ]]; then
        args+=" --logo-type iterm --logo ${myenv_path}/xelloss.jpg --logo-width 50 --logo-height 20"
    fi
    eval fastfetch ${args}
elif which neofetch > /dev/null 2>&1; then
    args=""
    if [[ $term_program == *"iterm"* ]]; then
        args+"--backend iterm2 --size 300 --source ${myenv_path}/xelloss.jpg"
    fi
    eval neofetch ${args}
elif which screenfetch > /dev/null 2>&1; then
    screenfetch -E
fi

# fortune + cowsay welcome message
msg="ysoftman"
if which fortune > /dev/null 2>&1; then
    msg=$(fortune -s 2> /dev/null)
    if [[ $msg == '' ]]; then
        msg=$(fortune)
    fi
fi

if which figlet > /dev/null 2>&1; then
    banner=$(figlet ysoftman 2> /dev/null)
    msg="${banner}\n${msg}"
fi

if which cowsay > /dev/null 2>&1; then
    # print cowsay list number
    # cnt=0; for i in $(cowsay -l | sed 1d); do echo "$((cnt++)) $i"; done;
    # cowfile 랜덤으로 선택
    cowfile=""
    cnt=0
    random=$(( RANDOM % $(cowsay -l | sed 1d | wc -w ) ))
    # echo $random
    for i in $(cowsay -l | sed 1d); do
        if [[ $cnt == $random ]]; then
            if [[ $i == "sodomized" ]] || [[ $i == "telebears" ]]; then
                printf "change rude coway type to cheese!\n"
                i="cheese"
            fi
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
unset msg

# prezto .zlogin fortune 을 실행하고 있어 .zlogin 에서 fortune 실행을 주석처리했다.
