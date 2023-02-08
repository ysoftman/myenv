#!/usr/local/bin/zsh

rm -rfv ~/.oh-my-zsh
# tools/install.sh 로 설치하면 .zshrc 를 새로 만들기 때문에 사용하지 않는다.
git clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh

# 미리 설정한 template 파일을 복사
# .zshrc 에서 ~/.oh-my-zsh/templates/zshrc.zsh-template 로드하여 사용
cp -v zshrc.zsh-template ~/.oh-my-zsh/templates/zshrc.zsh-template
# 미리 설정한 agnoster 테마 파일을 복사
cp -v agnoster.zsh-theme ~/.oh-my-zsh/themes/agnoster.zsh-theme
