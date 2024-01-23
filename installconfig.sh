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

temp=$(delta --version 2> /dev/null)
if [[ $? == 0 ]]; then
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global add.interactive.userBuiltin "false"
    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global delta.line-numbers "true"
    git config --global delta.side-by-side "true"
    git config --global delta.syntax-theme "OneHalfDark"
fi

# 파일로 저장하지 않고 일정시간(디폴트 15분)동안 id,pw 를 캐싱한다.
#git config --global credential.helper cache
# save credential(password)
git config --global credential.helper store

# gitignore, bash, zsh, vim, tmux, tigrc, mutt 등 기본 설정
export XDG_CONFIG_HOME="$HOME/.config"
[ -h ~/.gitignore_global ] && unlink ~/.gitignore_global
[ -h ~/.bashrc ] && unlink ~/.bashrc
[ -h ~/.zshrc ] && unlink ~/.zshrc
[ -h ~/.vimrc ] && unlink ~/.vimrc
[ -h ${XDG_CONFIG_HOME}/nvim ] && unlink ${XDG_CONFIG_HOME}/nvim
[ -h ~/.tmux.conf ] && unlink ~/.tmux.conf
[ -h ~/.tigrc ] && unlink ~/.tigrc
[ -h ~/.muttrc ] && unlink ~/.muttrc
[ -h ~/.alacritty.toml ] && unlink ~/.alacritty.toml
# install alacritty theme
[ -d ~/.alacritty-colorscheme ] || git clone https://github.com/eendroroy/alacritty-theme.git ~/.alacritty-colorscheme
[ -h ${XDG_CONFIG_HOME}/zellij ] && unlink ${XDG_CONFIG_HOME}/zellij
[ -h ${XDG_CONFIG_HOME}/mc ] && unlink ${XDG_CONFIG_HOME}/mc
[ -h ${XDG_CONFIG_HOME}/lsd ] && unlink ${XDG_CONFIG_HOME}/lsd
[ -h ${XDG_CONFIG_HOME}/k9s ] && unlink ${XDG_CONFIG_HOME}/k9s

# backup previous settings
[ -f ~/.gitignore_global ] && mv -fv ~/.gitignore_global ~/.gitignore_global.bak
[ -f ~/.bashrc ] && mv -fv ~/.bashrc ~/.bashrc.bak
[ -f ~/.zshrc ] && mv -fv ~/.zshrc ~/.zshrc.bak
[ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
[ -f ${XDG_CONFIG_HOME}/nvim/init.vim ] && mv -fv ${XDG_CONFIG_HOME}/nvim ${XDG_CONFIG_HOME}/nvim.bak
[ -f ~/.tmux.conf ] && mv -fv ~/.tmux.conf ~/.tmux.conf.bak
[ -f ~/.tigrc ] && mv -fv ~/.tigrc ~/.tigrc.bak
[ -f ~/.muttrc ] && mv -fv ~/.muttrc ~/.muttrc.bak
[ -f ~/.alacritty.toml ] && mv -fv ~/.alacritty.toml ~/.alacritty.toml.bak
[ -d ${XDG_CONFIG_HOME}/zellij ] && mv -fv ${XDG_CONFIG_HOME}/zellij ${XDG_CONFIG_HOME}/zellij.bak
[ -d ${XDG_CONFIG_HOME}/mc ] && mv -fv ${XDG_CONFIG_HOME}/mc ${XDG_CONFIG_HOME}/mc.bak
[ -d ${XDG_CONFIG_HOME}/lsd ] && mv -fv ${XDG_CONFIG_HOME}/lsd ${XDG_CONFIG_HOME}/lsd.bak

# ubuntu 에서는 이름이 달라서 link 처리한다.
[ -f /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/bin/fd
[ -f /usr/bin/batcat ] && sudo ln -sf /usr/bin/batcat /usr/bin/bat

ln -sf ${PWD}/.gitignore_global ~/.gitignore_global
ln -sf ${PWD}/.bashrc ~/.bashrc
ln -sf ${PWD}/.zshrc ~/.zshrc
ln -sf ${PWD}/.vimrc ~/.vimrc
ln -sf ${PWD}/nvim ${XDG_CONFIG_HOME}/nvim
ln -sf ${PWD}/.tmux.conf ~/.tmux.conf
ln -sf ${PWD}/.tigrc ~/.tigrc
ln -sf ${PWD}/.muttrc ~/.muttrc
ln -sf ${PWD}/.alacritty.toml ~/.alacritty.toml
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/zellij ${XDG_CONFIG_HOME}/zellij
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/mc ${XDG_CONFIG_HOME}/mc
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/lsd ${XDG_CONFIG_HOME}/lsd
ln -sf ${PWD}/k9s ${XDG_CONFIG_HOME}/k9s

# wsl 환경인 경우 wsl.conf 설정
if [[ $(uname -a) == *"microsoft"* ]]; then
    # link 적용 안됨
    # sudo ln -sf ${PWD}/wsl.conf /etc/wsl.conf
    sudo unlink /etc/wsl.conf 2> /dev/null
    sudo cp -fv ${PWD}/wsl.conf /etc/wsl.conf
    echo "윈도우 실행에서 wsl -t ubuntu 로 종료 후 터미널 다시 시작 필요"
fi

# 보안사항으로 커밋하면 안됨.
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 커밋하면 안됨.
#sudo cp -fv hosts /etc/hosts
