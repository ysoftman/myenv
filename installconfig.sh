#!/bin/bash

# git config
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global color.ui auto
git config --global core.editor vim
git config --global merge.tool vimdiff

# bash, zsh, vim 기본 설정
cp -fv ./.bashrc ~/.bashrc
cp -fv ./.zshrc ~/.zshrc
cp -fv ./.vimrc ~/.vimrc

# 보안사항으로 실제 필요할때만 사용하자
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 실제 필요할때만 사용하자
#sudo cp -fv hosts /etc/hosts
