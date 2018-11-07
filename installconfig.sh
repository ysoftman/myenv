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
[ -h ~/.gitignore_global ] && unlink ~/.gitignore_global; ln -s ~/workspace/myenv/.gitignore_global ~/.gitignore_global

# bash, zsh, vim 기본 설정
[ -h ~/.bashrc ] && unlink ~/.bashrc; ln -s ~/workspace/myenv/.bashrc ~/.bashrc
[ -h ~/.zshrc ] && unlink ~/.zshrc; ln -s ~/workspace/myenv/.zshrc ~/.zshrc
[ -h ~/.vimrc ] && unlink ~/.vimrc; ln -s ~/workspace/myenv/.vimrc ~/.vimrc
[ -h ~/.tmux.conf ] && unlink ~/.tmux.conf; ln -s ~/workspace/myenv/.tmux.conf ~/.tmux.conf

# dosbox 설정
[ -h ~/dosbox.conf ] && unlink ~/dosbox.conf; ln -s ~/workspace/myenv/dosbox.conf ~/dosbox.conf
[ -h ~/dosbox.sh ] && unlink ~/dosbox.sh; ln -s ~/workspace/myenv/dosbox.sh ~/dosbox.sh

# pythonpath 설정
[ -h ~/pythonpath.sh ] && unlink ~/pythonpath.sh; ln -s ~/workspace/myenv/pythonpath.sh ~/pythonpath.sh

# warcraft3 창모드로 실행 스크립트
[ -h ~/warcraft3_window.sh ] && unlink ~/warcraft3_window.sh; ln -s ~/workspace/myenv/warcraft3_window.sh ~/warcraft3_window.sh

# 보안사항으로 커밋하면 안됨.
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 커밋하면 안됨.
#sudo cp -fv hosts /etc/hosts
