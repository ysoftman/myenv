#!/usr/local/bin/zsh
if [ -d ${ZDOTDIR:-$HOME}/.zprezto ]; then
    rm -rf ${ZDOTDIR:-$HOME}/.zprezto
fi
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

rm -fv ${HOME}/.zprezto/runcoms/zpreztorc
ln -sv ${PWD}/zpreztorc ${HOME}/.zprezto/runcoms/zpreztorc
rm -fv ${HOME}/.zprezto/runcoms/zlogin
ln -sv ${PWD}/zlogin ${HOME}/.zprezto/runcoms/zlogin

echo "If you want to use 'ysoftman-customized sorin prompt', press y"
read answer
answer=$(echo ${answer} | tr '[:upper:]' '[:lower:]')
if [[ ${answer} == 'y' ]]; then
    echo 'Yes'
    rm -fv ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup
    ln -sv ${PWD}/prompt_sorin_setup ${HOME}/.zprezto/modules/prompt/functions/prompt_sorin_setup
fi

#echo 'source ${HOME}/.zprezto/init.zsh' >> ~/.zshrc
source ${HOME}/.zprezto/init.zsh
