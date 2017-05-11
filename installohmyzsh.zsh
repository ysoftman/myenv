#!/usr/local/bin/zsh

rm -rfv ~/.oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# 미리 설정한 template 파일을 복사
# .zshrc 에서 ~/.oh-my-zsh/templates/zshrc.zsh-template 로드하여 사용
cp -v zshrc.zsh-template ~/.oh-my-zsh/templates/zshrc.zsh-template

