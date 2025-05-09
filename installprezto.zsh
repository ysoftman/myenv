#!/bin/zsh
if [ -d ${ZDOTDIR:-$HOME}/.zprezto ]; then
    rm -rf ${ZDOTDIR:-$HOME}/.zprezto
fi
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

[ -h ${HOME}/.zprezto/runcoms/zlogin ] && unlink ${HOME}/.zprezto/runcoms/zlogin
[ -h ${HOME}/.zprezto/runcoms/zpreztorc ] && unlink ${HOME}/.zprezto/runcoms/zpreztorc
[ -h ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup ] && unlink ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup

[ -f ${HOME}/.zprezto/runcoms/zlogin ] && mv -fv ${HOME}/.zprezto/runcoms/zlogin ${HOME}/.zprezto/runcoms/zlogin.bak
[ -f ${HOME}/.zprezto/runcoms/zpreztorc ] && mv -fv ${HOME}/.zprezto/runcoms/zpreztorc ${HOME}/.zprezto/runcoms/zpreztorc.bak
[ -f ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup ] && mv -fv ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup.bak

ln -sfv ${PWD}/prezto/zlogin ${HOME}/.zprezto/runcoms/zlogin
ln -sfv ${PWD}/prezto/zpreztorc ${HOME}/.zprezto/runcoms/zpreztorc
ln -sfv ${PWD}/prezto/prompt_sorin_ysoftman_setup ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_ysoftman_setup

#echo 'source ${HOME}/.zprezto/init.zsh' >> ~/.zshrc
source ${HOME}/.zprezto/init.zsh
