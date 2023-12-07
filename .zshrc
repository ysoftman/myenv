# zsh 프로파일링할때 사용
#zmodload zsh/zprof

# zellij 에서 SHELL 값으로 쉘을 시작한다.
# apple silicon(arm64) zsh 가 있다면 이걸 사용한다.
if [ -x /opt/homebrew/bin/zsh ]; then
    export SHELL=/opt/homebrew/bin/zsh
    export PATH=/opt/homebrew/bin:$PATH
fi

# multiplexer="tmux"
multiplexer="zellij"
# ${multiplexer} 시작되면 환경변수값이 설정된다.
# 이를 기준으로 ${multiplexer} 가 한번만 실행되도록 한다.
if [ $multiplexer = "tmux" ]; then
    multiplexer_already_started=$TMUX
elif [ $multiplexer = "zellij" ]; then
    multiplexer_already_started=$ZELLIJ
fi

eval "type ${multiplexer}"
if [[ $? == 0 && -z "$multiplexer_already_started" ]]; then
    # 터미널 시작시 바로 tmux 전환시 signal 6(abort) 되는 환경도 있어 물어본다.
    echo "start ${multiplexer}? (y/n, default:y)"
    read answer
    if [ -z $answer ] || [ $(echo $answer | tr '[:upper:]' '[:lower:]') = 'y' ]; then
        # exec 로 현재 프로세스를 ${multiplexer} 프로세스로 대체(replace)한다.
        exec ${multiplexer}
    fi
fi

[ -f ~/workspace/myenv/myenv.sh ] && source ~/workspace/myenv/myenv.sh
[ -f ~/workspace/bill-ysoftman/env.sh ] && source ~/workspace/bill-ysoftman/env.sh

### Added by Zplugin's installer
#source '/Users/ysoftman/.zplugin/bin/zplugin.zsh'
#autoload -Uz _zplugin
#(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



#####
# ctrl-r 사용시 위젯 함수에 +m(--no-multi)가 고정되어 있어, +m 를 뺀 위젯 함수를 덮어쓴다.
# 참고 https://github.com/junegunn/fzf/issues/1806#issuecomment-570758721
# +m 제거 외에도 multi 선택을 사용할 수 있도록 수정한 버전
# zsh 에만 동작이 보장되어 정식 머지된것은 아님
# multi 동작하는 함수 구현해 임시로 사용
# https://github.com/junegunn/fzf/pull/2098
fzf-history-widget() {
local selected num selected_lines selected_line selected_line_arr
setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

# Read history lines (split on newline) into selected_lines array.
selected_lines=(
    "${(@f)$(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} -m" $(__fzfcmd))}"
)
local ret=$?

# Remove empty elements, converting ('') to ().
selected_lines=($selected_lines)
if [[ "${#selected_lines[@]}" -ne 0 ]]; then
    local -a history_lines=()
    for selected_line in "${selected_lines[@]}"; do
    # Split each history line on spaces, and take the 1st value (history line number).
    selected_line_arr=($=selected_line)
    num=$selected_line_arr[1]
    if [[ -n "$num" ]]; then
        # Add history at line $num to history_lines array.
        zle vi-fetch-history -n $num
        history_lines+=("$BUFFER")
        BUFFER=
    fi
    done
    # Set input buffer to newline-separated list of history lines.
    # Use echo to unescape, e.g. \n to newline, \t to tab.
    BUFFER="${(F)history_lines}"
    # Move cursor to end of buffer.
    CURSOR=$#BUFFER
fi

zle reset-prompt
return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget
#####


# fzf 등의 화면이 계속 갱신되어 사라지는 문제가 있어 사용하지 않음
# 1초마다 프롬프트 리셋하여, 프롬프트내의 현재시간을 업데이트한다.
# TMOUT=1
# TRAPALRM() { zle reset-prompt }

export NVM_DIR="$HOME/.config/nvm"
# nmv.sh 로딩 속도가 느려서 사용하지 않기로 함
# https://github.com/nvm-sh/nvm/issues/2724
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# --no-use 를 옵션을 사용해 로딩하면 nvm 명령은 사용할 수 있지만 새로운 쉘 시작시 항상 system node 가 되어
# 특정 node 버전이 필요한 경우 nvm use v{버전} 으로 변경해야 하는 수고가 있다.
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/mc mc

# --alias : prints alias for current shell, fuck() 함수 내용 출력
# eval $(thefuck --alias)


# zsh 프로파일링할때 사용
#zprof


# deno
if [ -d "${HOME}/.deno" ]; then
    export DENO_INSTALL="${HOME}/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi


# bun completions
[ -s "/Users/ysoftman/.bun/_bun" ] && source "/Users/ysoftman/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
