#!/bin/bash

# git config
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global color.ui auto
git config --global core.editor vim
# 윈도우에서만 autocrlf 활성화 하자, 기본은 false
git config --global core.autocrlf false
git config --global merge.tool vimdiff
# 이미 사용자 정보가 설정되어 있으면 덮어쓰기때문에 확인하고 사용하자
user_email="ysoftman@gmail.com"
user_name="ysoftman"
echo -e "input git config --global user.email, default is ysoftman@gmail.com"
read answer
if [[ ${answer} != '' ]]; then
    user_email=${answer}
fi
echo "user.email:" ${user_email}
git config --global user.email ${user_email}

echo "input git config --global user.name, default is ysoftman"
read answer
if [[ ${answer} != '' ]]; then
    user_name=${answer}
fi
echo "user.name:" ${user_name}
git config --global user.name ${user_name}

# 파일로 저장하지 않고 일정시간(디폴트 15분)동안 id,pw 를 캐싱한다.
git config --global credential.helper cache

# git ignore
[ -h ~/.gitignore_global ] && unlink ~/.gitignore_global
[ -f ~/.gitignore_global ] && mv -fv ~/.gitignore_global ~/.gitignore_global.bak
ln -s ${PWD}/.gitignore_global ~/.gitignore_global

# bash, zsh, vim, tmux, tigrc, mutt 기본 설정
[ -h ~/.bashrc ] && unlink ~/.bashrc
[ -h ~/.zshrc ] && unlink ~/.zshrc
[ -h ~/.vimrc ] && unlink ~/.vimrc
[ -h ~/.tmux.conf ] && unlink ~/.tmux.conf
[ -h ~/.tigrc ] && unlink ~/.tigrc
[ -h ~/.muttrc ] && unlink ~/.muttrc
[ -h ~/.config/mc ] && unlink ~/.config/mc

[ -f ~/.bashrc ] && mv -fv ~/.bashrc ~/.bashrc.bak
[ -f ~/.zshrc ] && mv -fv ~/.zshrc ~/.zshrc.bak
[ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
[ -f ~/.tmux.conf ] && mv -fv ~/.tmux.conf ~/.tmux.conf.bak
[ -f ~/.tigrc ] && mv -fv ~/.tigrc ~/.tigrc.bak
[ -f ~/.muttrc ] && mv -fv ~/.muttrc ~/.muttrc.bak
[ -d ~/.config/mc ] && mv -fv ~/.config/mc ~/.config/mc_bak

ln -s ${PWD}/.bashrc ~/.bashrc
ln -s ${PWD}/.zshrc ~/.zshrc
ln -s ${PWD}/.vimrc ~/.vimrc
ln -s ${PWD}/.tmux.conf ~/.tmux.conf
ln -s ${PWD}/.tigrc ~/.tigrc
ln -s ${PWD}/.muttrc ~/.muttrc
[ -d ~/.config ] && ln -s ${PWD}/mc ~/.config/mc

# dosbox 설정
[ -h ~/dosbox.conf ] && unlink ~/dosbox.conf
[ -h ~/dosbox.sh ] && unlink ~/dosbox.sh
ln -s ${PWD}/dosbox.conf ~/dosbox.conf
ln -s ${PWD}/dosbox.sh ~/dosbox.sh

# pythonpath 설정
[ -h ~/pythonpath.sh ] && unlink ~/pythonpath.sh
ln -s ${PWD}/pythonpath.sh ~/pythonpath.sh

# warcraft3 창모드로 실행 스크립트
[ -h ~/warcraft3_window.sh ] && unlink ~/warcraft3_window.sh
ln -s ${PWD}/warcraft3_window.sh ~/warcraft3_window.sh

# xelloss 이미지 링크
[ -h ~/xelloss.jpg ] && unlink ~/xelloss.jpg
ln -s ${PWD}/xelloss.jpg ${HOME}/xelloss.jpg

# 보안사항으로 커밋하면 안됨.
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 커밋하면 안됨.
#sudo cp -fv hosts /etc/hosts
