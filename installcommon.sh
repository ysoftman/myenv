#!/bin/bash
# android
pkgs_pkg='zsh vim neovim curl git tig tmux cmake ctags fortune cowsay figlet cmatrix python ruby golang rust man dnsutils ripgrep fd fzf lua53 openssh libandroid-support tsu zoxide lsd bat wget which htop fastfetch neofetch git-delta difftastic jq nodejs gping eza gitui grex hyperfine jless procs sd zellij duf dust'
# redhat,centos
pkgs_yum='zsh vim curl git tig tmux cmake ctags fortune cowsay figlet cmatrix python python-dev ruby golang rust cargo man dnsutils python3-pip clang-format ncurses ncurses-devel git-delta jq'
# debian,ubuntu
pkgs_aptget='zsh vim curl git tig tmux cmake ctags fortune cowsay figlet cmatrix python python-dev python3-dev default-jdk ruby golang rust cargo man dnsutils python3-pip expect clang-format build-essential libncurses5-dev jq screenfetch neofetch lolcat fonts-powerline ripgrep bat fd-find lsd duf fzf'
# arch
pkgs_pacman='zsh vim curl git tig tmux cmake ctags fortune-mod cowsay figlet cmatrix python ruby go man dnsutils screenfetch fastfetch neofetch lolcat lsd eza git-delta'
# mac
pkgs_brew='zsh zoxide lsd eza rust git-delta ripgrep bat duf lolcat cowsay jq fastfetch neofetch'
sudo_cmd='sudo'

if [[ $(uname -o 2>/dev/null) == 'Android' ]]; then
    sudo_cmd=''
    package_program="pkg"
    ${sudo_cmd} ${package_program} update
    ${sudo_cmd} ${package_program} upgrade -y
    ${sudo_cmd} ${package_program} install -y ${pkgs_pkg}
    # vim, vim-python 한번에 설치시 의존성 에러 발생해 별도 설치
    ${sudo_cmd} ${package_program} install -y vim-python
    gem install lolcat
    chsh -s zsh
    exit 0
elif [[ $(uname) == 'Darwin' ]]; then
    echo 'OSX Environment'
    # brew 설치
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install ${pkgs_brew}
elif [[ $(uname) == 'Linux' ]]; then
    echo 'Linux Environment'
    # centos
    if yum --version >/dev/null 2>&1; then
        package_program="yum"
        ${sudo_cmd} ${package_program} update
        ${sudo_cmd} ${package_program} install -y ${pkgs_yum}
    else
        # ubuntu
        if apt --version >/dev/null 2>&1; then
            package_program="apt"
            ${sudo_cmd} ${package_program} update
            # 여러 패키지중 존재하지 않은 패키지가 포함되면 "E: Unable to locate package xxx" 에러가 발생하고 패키지가 하나도 설치 되지 않는다.
            # --ignore-missing 옵션이 있지만, 이 옵션은 apt 패키지가 존재하고 다운로드할 수 없는 상황에서만 해당 패키지를 무시하고 계속 진행한다.
            # ${sudo_cmd} ${package_program} install -y ${pkgs_aptget}
            for i in ${pkgs_aptget}; do
                ${sudo_cmd} ${package_program} install -y $i
            done
        fi
        # archlinux
        if pacman --version >/dev/null 2>&1; then
            package_program="pacman"
            ${sudo_cmd} ${package_program} -Sy
            ${sudo_cmd} ${package_program} -S ${pkgs_pacman} --noconfirm
        fi
    fi

    # export LC_ALL=ko_KR.utf8 사용을 위해서 정의되어 있어야 한다.
    ${sudo_cmd} localedef -f UTF-8 -i ko_KR ko_KR.utf8

else
    echo 'This OS is not (Android or OS-X or Linux)'
    exit 1
fi
