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
# user_email="ysoftman@gmail.com"
# user_name="ysoftman"
# 이미 사용자 정보가 설정되어 있으면 덮어쓰기때문에 확인하고 사용하자
echo -e "(current) git config --global user.email: $(git config --global user.email)"
echo -ne "(new) git config --global user.email: (empty to keep current user email)"
read answer
if [[ ${answer} != '' ]]; then
    user_email=${answer}
    echo "user.email:" ${user_email}
    git config --global user.email ${user_email}
fi

echo -e "(current) git config --global user.name: $(git config --global user.name)"
echo -ne "(new) git config --global user.name: (empty to keep current user name)"
read answer
if [[ ${answer} != '' ]]; then
    user_name=${answer}
    echo "user.name:" ${user_name}
    git config --global user.name ${user_name}
fi

# 파일로 저장하지 않고 일정시간(디폴트 15분)동안 id,pw 를 캐싱한다.
git config --global credential.helper cache

# gitignore, bash, zsh, vim, tmux, tigrc, mutt 등 기본 설정
[ -h ~/.gitignore_global ] && unlink ~/.gitignore_global
[ -h ~/.bashrc ] && unlink ~/.bashrc
[ -h ~/.zshrc ] && unlink ~/.zshrc
[ -h ~/.vimrc ] && unlink ~/.vimrc
[ -h ~/.tmux.conf ] && unlink ~/.tmux.conf
[ -h ~/.tigrc ] && unlink ~/.tigrc
[ -h ~/.muttrc ] && unlink ~/.muttrc
[ -h ~/.alacritty.yml ] && unlink ~/.alacritty.yml
[ -h ~/.config/mc ] && unlink ~/.config/mc
[ -h ~/.k9s/skin.yml ] && unlink ~/.k9s/skin.yml

[ -f ~/.gitignore_global ] && mv -fv ~/.gitignore_global ~/.gitignore_global.bak
[ -f ~/.bashrc ] && mv -fv ~/.bashrc ~/.bashrc.bak
[ -f ~/.zshrc ] && mv -fv ~/.zshrc ~/.zshrc.bak
[ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
[ -f ~/.tmux.conf ] && mv -fv ~/.tmux.conf ~/.tmux.conf.bak
[ -f ~/.tigrc ] && mv -fv ~/.tigrc ~/.tigrc.bak
[ -f ~/.muttrc ] && mv -fv ~/.muttrc ~/.muttrc.bak
[ -f ~/.alacritty.yml ] && mv -fv ~/.alacritty.yml ~/.alacritty.yml.bak
[ -d ~/.config/mc ] && mv -fv ~/.config/mc ~/.config/mc.bak
[ -f ~/.k9s/skin.yml ] && mv -fv ~/.k9s/skin.yml ~/.k9s/skin.yml.bak

ln -sf ${PWD}/.gitignore_global ~/.gitignore_global
ln -sf ${PWD}/.bashrc ~/.bashrc
ln -sf ${PWD}/.zshrc ~/.zshrc
ln -sf ${PWD}/.vimrc ~/.vimrc
ln -sf ${PWD}/.tmux.conf ~/.tmux.conf
ln -sf ${PWD}/.tigrc ~/.tigrc
ln -sf ${PWD}/.muttrc ~/.muttrc
ln -sf ${PWD}/.alacritty.yml ~/.alacritty.yml
[ -d ~/.config ] && ln -sf ${PWD}/mc ~/.config/mc
[ -d ~/.k9s ] && ln -sf ${PWD}/.k9s/skins/one_dark.yml ~/.k9s/skin.yml
ln -sf ${PWD}/dosbox.conf ~/dosbox.conf
ln -sf ${PWD}/dosbox.sh ~/dosbox.sh
ln -sf ${PWD}/pythonpath.sh ~/pythonpath.sh
ln -sf ${PWD}/warcraft3_window.sh ~/warcraft3_window.sh
ln -sf ${PWD}/xelloss.jpg ${HOME}/xelloss.jpg

# wsl 환경인 경우 wsl.conf 설정
if [[ $(uname -a) == *"microsoft"* ]]; then
    # link 적용 안됨
    # sudo ln -sf ${PWD}/wsl.conf /etc/wsl.conf
    sudo unlink /etc/wsl.conf 2> /dev/null
    sudo cp -fv ${PWD}/wsl.conf /etc/wsl.conf
    echo "윈도우 실행에서 wsl -t ubuntu-18.04 로 종료후 터미널 다시 시작 필요"
fi

# 보안사항으로 커밋하면 안됨.
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 커밋하면 안됨.
#sudo cp -fv hosts /etc/hosts
