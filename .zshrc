# prezto 사용
source ~/.zprezto/init.zsh

# oh-my-zsh 사용
#source ~/.oh-my-zsh/templates/zshrc.zsh-template

# blackvoidzsh 사용
# source ~/.BlaCk-Void-Zsh/BlaCk-Void.zshrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/workspace/myenv/myenv.sh ] && source ~/workspace/myenv/myenv.sh
[ -f ~/workspace/usf-ysoftman/usfenv.sh ] && source ~/workspace/usf-ysoftman/usfenv.sh

export NVM_DIR="/Users/ysoftman/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

### Added by Zplugin's installer
#source '/Users/ysoftman/.zplugin/bin/zplugin.zsh'
#autoload -Uz _zplugin
#(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk
