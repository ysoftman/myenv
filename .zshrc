# prezto 사용
source ~/.zprezto/init.zsh

# oh-my-zsh 사용
#source ~/.oh-my-zsh/templates/zshrc.zsh-template


#export LSCOLORS=GxFxCxDxBxegedabagaced
export CLICOLOR=1
export GOPATH=$HOME/workspace/gopath
export PATH=$PATH:$HOME:$GOPATH/bin:
export PATH=$PATH:/usr/local/opt/openssl/bin:

export PYTHONPATH=/Library/Python/2.7/site-packages
#export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python3.6/site-packages
export EDITOR=vim
export VISUAL=vim

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias vi='vim'
alias ll='ls -ahlG'
alias gopath='cd $GOPATH'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'
alias cutstring='$HOME/workspace/cutstring/cutstring'
alias aleng='cd ~/workspace/aleng/ && aleng && cd -'

# for osx
alias sn='pmset displaysleepnow'

source ~/workspace/usf-ysoftman/.usfrc

