#!/usr/local/bin/zsh
rm -rfv ~/.zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

rm -fv ${HOME}/.zprezto/runcoms/zpreztorc
cp -fv zpreztorc ${HOME}/.zprezto/runcoms/zpreztorc
rm -fv ${HOME}/.zprezto/runcoms/zlogin
cp -fv zlogin ${HOME}/.zprezto/runcoms/zlogin
rm -fv ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup
cp -fv prompt_sorin_setup ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup

#echo 'source ${HOME}/.zprezto/init.zsh' >> ~/.zshrc
source ${HOME}/.zprezto/init.zsh
