export PS1="\u@\h:\w\$ "
myenv_path="$HOME/workspace/myenv"

[ -f ${myenv_path}/myenv.sh ] && source ${myenv_path}/myenv.sh
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nvm -> mise 로 대체
# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# . "$HOME/.cargo/env"
# volta -> mise 로 대체
# export VOLTA_HOME="$HOME/.volta"
# export PATH="$VOLTA_HOME/bin:$PATH"

# mise
[ -f ~/.local/bin/mise ] && eval "$(~/.local/bin/mise activate bash)"
[ -f /opt/homebrew/bin/mise ] && eval "$(/opt/homebrew/bin/mise activate bash)"
