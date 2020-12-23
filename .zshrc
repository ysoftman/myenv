# tmux 시작되면 TMUX 환경변수값이 설정되어 tmux 가 한번만 실행되도록 한다.
# exec 로 현재 프로세스를 tmux 프로세스로 대체(replace)한다.
if [ -z "$TMUX" ]; then exec tmux; fi

if [[ $(uname -a | grep -i android) ]]; then
    # oh-my-zsh 사용
    source ~/.oh-my-zsh/templates/zshrc.zsh-template
else
    # prezto 사용
    source ~/.zprezto/init.zsh
fi

# $(brew --prefix)/opt/fzf/install 실행하면 .fzf.bash .fzf.zsh 파일이 생긴다.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
