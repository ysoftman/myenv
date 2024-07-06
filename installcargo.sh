#!/bin/bash

declare -A mpkgs
# package_name = package_binary_name
mpkgs["alacritty"]="alacritty"
mpkgs["bandwhich"]="bandwhich"
mpkgs["bat"]="bat"
mpkgs["bottom"]="btm"
mpkgs["cfonts"]="cfonts"
mpkgs["delta"]="delta"
mpkgs["diskonaut"]="diskonaut"
mpkgs["dog"]="dog"
mpkgs["du-dust"]="dust"  # brew 에선 dust 패키지 이름으로 사용된다.
mpkgs["exa"]="exa"
mpkgs["fd-find"]="fd"
mpkgs["gitui"]="gitui"
mpkgs["grex"]="grex"
mpkgs["hexyl"]="hexyl"
mpkgs["hwatch"]="hwatch"
mpkgs["hyperfine"]="hyperfine"
mpkgs["jless"]="jless"
mpkgs["lsd"]="lsd"
mpkgs["nu"]="nu" # nushell
mpkgs["ohmystock"]="ohmystock"
mpkgs["onefetch"]="onefetch"
mpkgs["procs"]="procs"
mpkgs["ripgrep"]="rg"
mpkgs["sd"]="sd"
mpkgs["termscp"]="termscp"
mpkgs["termusic"]="termusic"
mpkgs["termusic-server"]="termusic-server"
mpkgs["tokei"]="tokei"
mpkgs["whome"]="whome"
mpkgs["ytop"]="ytop"
mpkgs["zellij"]="zellij"
mpkgs["zenith"]="zenith"
mpkgs["zoxide"]="zoxide"

# brew 로 설치해보기
#if [[ $(uname) == 'Darwin' ]]; then
#    for p in ${pkgs}; do
#        brew install $p
#    done
#fi

install_pkgs=""
uninstall_pkgs=""
for pkg_name in ${!mpkgs[@]}; do
    pkg_binary_name=${mpkgs[$pkg_name]}
    echo $pkg_binary_name
    # brew 로 설치된 패키지는 cargo 로 설치 하지 않는 로직
    if [[ $(uname) == 'Darwin' ]]; then
        if [[ $(type -a $pkg_binary_name | grep -iE "/local/bin/|/homebrew/bin/") == *"$pkg_binary_name"* ]]; then
            uninstall_pkgs+="$pkg_name "
            continue
        fi
    fi
    install_pkgs+="$pkg_name "
done
echo "install_pkgs=$install_pkgs"
echo "uninstall_pkgs=$uninstall_pkgs"

# rustup 을 설치해서 rustc/cargo 버전을 올려보자.
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# cargo 가 제대로 동작하지 않는다면 다음과 같이 삭제 후 재설치한다.
#rustup uninstall stable && rustup install stable

rustup update
cargo install ${install_pkgs}
cargo uninstall ${uninstall_pkgs} 2> /dev/null

echo "-- show installed packages by cargo --"
cargo install --list | awk 'NR%2==0 {print $1}'

