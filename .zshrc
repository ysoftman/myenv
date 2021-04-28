# tmux 시작되면 TMUX 환경변수값이 설정되어 tmux 가 한번만 실행되도록 한다.
# exec 로 현재 프로세스를 tmux 프로세스로 대체(replace)한다.
if [ -z "$TMUX" ]; then
    # 터미널 시작시 바로 tmux 전환시 signal 6(abort) 되는 환경도 있어 물어본다.
    echo 'start tmux? (y/n, default:y)'
    read answer
    if [ -z $answer ] || [ $(echo $answer | tr '[:upper:]' '[:lower:]') = 'y' ]; then
        exec tmux
    fi
fi

[ -f ~/workspace/myenv/myenv.sh ] && source ~/workspace/myenv/myenv.sh
[ -f ~/workspace/usf-ysoftman/usfenv.sh ] && source ~/workspace/usf-ysoftman/usfenv.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


### Added by Zplugin's installer
#source '/Users/ysoftman/.zplugin/bin/zplugin.zsh'
#autoload -Uz _zplugin
#(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ysoftman/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ysoftman/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ysoftman/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ysoftman/google-cloud-sdk/completion.zsh.inc'; fi
fpath+=${ZDOTDIR:-~}/.zsh_functions

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzf 등의 화면이 계속 갱신되어 사라지는 문제가 있어 사용하지 않음
# 1초마다 프롬프트 리셋하여, 프롬프트내의 현재시간을 업데이트한다.
# TMOUT=1
# TRAPALRM() { zle reset-prompt }
