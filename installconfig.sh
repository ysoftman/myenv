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
# git config --global user.email "ysoftman@gmail.com"
# git config --global user.name "ysoftman"


# git ignore
cp -fv .gitignore_global ~


# bash, zsh, vim 기본 설정
unlink ~/.bashrc; ln -s ~/workspace/myenv/.bashrc ~/.bashrc
unlink ~/.zshrc; ln -s ~/workspace/myenv/.zshrc ~/.zshrc
unlink ~/.vimrc; ln -s ~/workspace/myenv/.vimrc ~/.vimrc
unlink ~/.tmux.conf; ln -s ~/workspace/myenv/.tmux.conf ~/.tmux.conf

# 보안사항으로 실제 필요할때만 사용하자
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 실제 필요할때만 사용하자
#sudo cp -fv hosts /etc/hosts
