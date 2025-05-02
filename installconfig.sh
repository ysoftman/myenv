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
read -r answer
if [[ ${answer} != '' ]]; then
    user_email=${answer}
    echo "user.email:" ${user_email}
    git config --global user.email ${user_email}
fi

echo -e "(current) git config --global user.name: $(git config --global user.name)"
echo -ne "(new) git config --global user.name: (empty to keep current user name)"
read -r answer
if [[ ${answer} != '' ]]; then
    user_name=${answer}
    echo "user.name:" ${user_name}
    git config --global user.name ${user_name}
fi

if delta --version 2>/dev/null 2>&1; then
    echo "set delta to git global config"
    git config --global core.pager 'delta --width=${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
    git config --global interactive.diffFilter "delta --color-only"
    git config --global add.interactive.userBuiltin "false"
    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global delta.line-numbers "true"
    git config --global delta.side-by-side "true"
    git config --global delta.syntax-theme "OneHalfDark"
fi
if difft --version 2>/dev/null 2>&1; then
    # `git log` with patches shown with difftastic.
    git config --global alias.dl '-c diff.external=difft log -p --ext-diff'
    # Show the most recent commit with difftastic.
    git config --global alias.ds '-c diff.external=difft show --ext-diff'
    # `git diff` with difftastic.
    git config --global alias.dft '-c diff.external=difft diff'
    # git forgit log
    git config --global alias.flog 'forgit log'
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
[ -h ~/.zprofile ] && unlink ~/.zprofile
[ -h ~/.vimrc ] && unlink ~/.vimrc
[ -h ${XDG_CONFIG_HOME}/nvim ] && unlink ${XDG_CONFIG_HOME}/nvim
[ -h ~/.tmux.conf ] && unlink ~/.tmux.conf
[ -h ~/.shellcheckrc ] && unlink ~/.shellcheckrc
[ -h ~/.tigrc ] && unlink ~/.tigrc
[ -h ~/.muttrc ] && unlink ~/.muttrc
[ -d ${XDG_CONFIG_HOME}/alacritty-colorscheme ] || git clone https://github.com/alacritty/alacritty-theme ${XDG_CONFIG_HOME}/alacritty-colorscheme
[ -h ${XDG_CONFIG_HOME}/alacritty ] && unlink ${XDG_CONFIG_HOME}/alacritty
[ -h ${XDG_CONFIG_HOME}/cava ] && unlink ${XDG_CONFIG_HOME}/cava
[ -h ${XDG_CONFIG_HOME}/harlequin ] && unlink ${XDG_CONFIG_HOME}/harlequin
[ -h ${XDG_CONFIG_HOME}/k9s ] && unlink ${XDG_CONFIG_HOME}/k9s
[ -h ${XDG_CONFIG_HOME}/karabiner ] && unlink ${XDG_CONFIG_HOME}/karabiner
[ -h ${XDG_CONFIG_HOME}/kitty ] && unlink ${XDG_CONFIG_HOME}/kitty
[ -h ${XDG_CONFIG_HOME}/lsd ] && unlink ${XDG_CONFIG_HOME}/lsd
[ -h ${XDG_CONFIG_HOME}/mc ] && unlink ${XDG_CONFIG_HOME}/mc
[ -h ${XDG_CONFIG_HOME}/zellij ] && unlink ${XDG_CONFIG_HOME}/zellij
[ -h ${XDG_CONFIG_HOME}/starship.toml ] && unlink ${XDG_CONFIG_HOME}/starship.toml

# backup previous settings
[ -f ~/.gitignore_global ] && mv -fv ~/.gitignore_global ~/.gitignore_global.bak
[ -f ~/.bashrc ] && mv -fv ~/.bashrc ~/.bashrc.bak
[ -f ~/.zshrc ] && mv -fv ~/.zshrc ~/.zshrc.bak
[ -f ~/.zprofile ] && mv -fv ~/.zprofile ~/.zprofile.bak
[ -f ~/.vimrc ] && mv -fv ~/.vimrc ~/.vimrc.bak
[ -f ${XDG_CONFIG_HOME}/nvim/init.vim ] && mv -fv ${XDG_CONFIG_HOME}/nvim ${XDG_CONFIG_HOME}/nvim.bak
[ -f ~/.tmux.conf ] && mv -fv ~/.tmux.conf ~/.tmux.conf.bak
[ -f ~/.shellcheckrc ] && mv -fv ~/.shellcheckrc ~/.shellcheckrc.bak
[ -f ~/.tigrc ] && mv -fv ~/.tigrc ~/.tigrc.bak
[ -f ~/.muttrc ] && mv -fv ~/.muttrc ~/.muttrc.bak
[ -d ${XDG_CONFIG_HOME}/alacritty ] && mv -fv ${XDG_CONFIG_HOME}/alacritty ${XDG_CONFIG_HOME}/alacritty.bak
[ -d ${XDG_CONFIG_HOME}/cava ] && mv -fv ${XDG_CONFIG_HOME}/cava ${XDG_CONFIG_HOME}/cava.bak
[ -d ${XDG_CONFIG_HOME}/harlequin ] && mv -fv ${XDG_CONFIG_HOME}/harlequin ${XDG_CONFIG_HOME}/harlequin.bak
[ -d ${XDG_CONFIG_HOME}/k9s ] && mv -fv ${XDG_CONFIG_HOME}/k9s ${XDG_CONFIG_HOME}/k9s.bak
[ -d ${XDG_CONFIG_HOME}/karabiner ] && mv -fv ${XDG_CONFIG_HOME}/karabiner ${XDG_CONFIG_HOME}/karabiner.bak
[ -d ${XDG_CONFIG_HOME}/kitty ] && mv -fv ${XDG_CONFIG_HOME}/kitty ${XDG_CONFIG_HOME}/kitty.bak
[ -d ${XDG_CONFIG_HOME}/lsd ] && mv -fv ${XDG_CONFIG_HOME}/lsd ${XDG_CONFIG_HOME}/lsd.bak
[ -d ${XDG_CONFIG_HOME}/mc ] && mv -fv ${XDG_CONFIG_HOME}/mc ${XDG_CONFIG_HOME}/mc.bak
[ -d ${XDG_CONFIG_HOME}/zellij ] && mv -fv ${XDG_CONFIG_HOME}/zellij ${XDG_CONFIG_HOME}/zellij.bak
[ -d ${XDG_CONFIG_HOME}/starship.toml ] && mv -fv ${XDG_CONFIG_HOME}/starship.toml ${XDG_CONFIG_HOME}/starship.toml.bak

ln -sf ${PWD}/.gitignore_global ~/.gitignore_global
ln -sf ${PWD}/.bashrc ~/.bashrc
ln -sf ${PWD}/.zshrc ~/.zshrc
ln -sf ${PWD}/.zprofile ~/.zprofile
ln -sf ${PWD}/.vimrc ~/.vimrc
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/nvim ${XDG_CONFIG_HOME}/nvim
ln -sf ${PWD}/.tmux.conf ~/.tmux.conf
ln -sf ${PWD}/.shellcheckrc ~/.shellcheckrc
ln -sf ${PWD}/.tigrc ~/.tigrc
ln -sf ${PWD}/.muttrc ~/.muttrc
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/alacritty ${XDG_CONFIG_HOME}/alacritty
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/cava ${XDG_CONFIG_HOME}/cava
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/harlequin ${XDG_CONFIG_HOME}/harlequin
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/karabiner ${XDG_CONFIG_HOME}/karabiner
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/k9s ${XDG_CONFIG_HOME}/k9s
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/kitty ${XDG_CONFIG_HOME}/kitty
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/lsd ${XDG_CONFIG_HOME}/lsd
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/mc ${XDG_CONFIG_HOME}/mc
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/zellij ${XDG_CONFIG_HOME}/zellij
[ -d ${XDG_CONFIG_HOME} ] && ln -sf ${PWD}/starship.toml ${XDG_CONFIG_HOME}/starship.toml

# ubuntu 에서는 이름이 달라서 link 처리한다.
[ -f /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/bin/fd
[ -f /usr/bin/batcat ] && sudo ln -sf /usr/bin/batcat /usr/bin/bat

# wsl 환경인 경우 wsl.conf 설정
if [[ $(uname -a) == *"microsoft"* ]]; then
    # link 적용 안됨
    # sudo ln -sf ${PWD}/wsl.conf /etc/wsl.conf
    sudo unlink /etc/wsl.conf 2>/dev/null
    sudo cp -fv ${PWD}/wsl.conf /etc/wsl.conf
    echo "윈도우 실행에서 wsl -t ubuntu 로 종료 후 터미널 다시 시작 필요"
fi

# 보안사항으로 커밋하면 안됨.
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 커밋하면 안됨.
#sudo cp -fv hosts /etc/hosts
