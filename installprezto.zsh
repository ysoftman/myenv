#!/usr/local/bin/zsh
rm -rfv ~/.zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

rm -fv ~/.zprezto/runcoms/zpreztorc
cp -fv zpreztorc ~/.zprezto/runcoms/zpreztorc

#echo 'source ~/.zprezto/init.zsh' >> ~/.zshrc
source ~/.zprezto/init.zsh
