export PS1="\u@\h:\w\$ "

[ -f ~/workspace/myenv/myenv.sh ] && source ~/workspace/myenv/myenv.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nvm -> mise 로 대체
# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# . "$HOME/.cargo/env"
# volta -> mise 로 대체
# export VOLTA_HOME="$HOME/.volta"
# export PATH="$VOLTA_HOME/bin:$PATH"
