[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -f ~/workspace/myenv/myenv.sh ] && source ~/workspace/myenv/myenv.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
