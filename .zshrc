# prezto 사용
#source ~/.zprezto/init.zsh

# oh-my-zsh 사용
source ~/.oh-my-zsh/templates/zshrc.zsh-template


#export LSCOLORS=GxFxCxDxBxegedabagaced
export CLICOLOR=1
export GOPATH=$HOME/workspace/gopath
export PATH=$PATH:$HOME:/opt/local/bin:$GOPATH/bin
export PYTHONPATH=$PYTHONPATH:/Library/Python/2.7/site-packages 
export EDITOR=vim
export VISUAL=vim

# for osx
alias sn='pmset displaysleepnow'
alias vi='vim'
alias ll='ls -ahlG'
alias work='cd ~/workspace'
alias testcode='cd ~/workspace/test_code'



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
