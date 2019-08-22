#!/usr/local/bin/zsh
if [ ! -d ${ZDOTDIR:-$HOME}/.zprezto ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
    git pull ${ZDOTDIR:-$HOME}/.zprezto
fi
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

rm -fv ${HOME}/.zprezto/runcoms/zpreztorc
ln -s ${PWD}/zpreztorc ${HOME}/.zprezto/runcoms/zpreztorc
rm -fv ${HOME}/.zprezto/runcoms/zlogin
ln -s ${PWD}/zlogin ${HOME}/.zprezto/runcoms/zlogin
rm -fv ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup
ln -s ${PWD}/prompt_sorin_setup ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup

#echo 'source ${HOME}/.zprezto/init.zsh' >> ~/.zshrc
source ${HOME}/.zprezto/init.zsh
