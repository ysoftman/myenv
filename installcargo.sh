#!/bin/bash

declare -A mpkgs
# package_name = package_binary_name
# mpkgs["coreutils"]="coreutils" # (https://github.com/uutils/coreutils) gnu binary 대체(굳이 설치할 필요가 없어서)
# mpkgs["exa"]="exa" # (https://github.com/ogham/exa) ls 대체(exa -> eza 로 대체 되었다.)
mpkgs["alacritty"]="alacritty"             # (https://github.com/alacritty/alacritty) kitty, iterm2 대체
mpkgs["bandwhich"]="bandwhich"             # (https://github.com/imsnif/bandwhich) iftop 대체
mpkgs["bat"]="bat"                         # (https://github.com/sharkdp/bat) cat 대체
mpkgs["bottom"]="btm"                      # (https://github.com/ClementTsang/bottom) top,htop 대체
mpkgs["cfonts"]="cfonts"                   # (https://github.com/dominikwilkowski/cfonts) toilet,figlet 대체
mpkgs["delta"]="delta"                     # (https://github.com/dandavison/delta) git diff
mpkgs["difftastic"]="difft"                # (https://github.com/wilfred/difftastic) git diff
mpkgs["diskonaut"]="diskonaut"             # (https://github.com/imsnif/diskonaut) du 대체
mpkgs["diskus"]="diskus"                   # (https://github.com/sharkdp/diskus) du 대체
mpkgs["dog"]="dog"                         # (https://github.com/ogham/dog) dig 대체
mpkgs["du-dust"]="dust"                    # (https://github.com/bootandy/dust) du 대체 brew 에선 dust 이름으로 사용
mpkgs["eza"]="eza"                         # (https://github.com/eza-community/eza) ls 대체
mpkgs["fd-find"]="fd"                      # (https://github.com/sharkdp/fd) find 대체
mpkgs["gitui"]="gitui"                     # (https://github.com/extrawurst/gitui) tig,lazygit 대체
mpkgs["gping"]="gping"                     # (https://github.com/orf/gping) ping 대체
mpkgs["grex"]="grex"                       # (https://github.com/pemistahl/grex) 정규표현식
mpkgs["hexyl"]="hexyl"                     # (https://github.com/sharkdp/hexyl) hexdump 대체
mpkgs["hwatch"]="hwatch"                   # (https://github.com/blacknon/hwatch) watch 대체
mpkgs["hyperfine"]="hyperfine"             # (https://github.com/sharkdp/hyperfine) time 대체
mpkgs["jless"]="jless"                     # (https://github.com/PaulJuliusMartinez/jless) jq,less 대체
mpkgs["lsd"]="lsd"                         # (https://github.com/Peltoche/lsd) ls 대체
mpkgs["nu"]="nu"                           # (https://github.com/nushell/nushell) bash 대체
mpkgs["oha"]="oha"                         # (https://github.com/hatoo/oha) 웹 부하 툴
mpkgs["ohmystock"]="ohmystock"             # (https://github.com/ysoftman/ohmystock) 개인적으로 만든 주식값 파악
mpkgs["onefetch"]="onefetch"               # (https://github.com/o2sh/onefetch) git 저장소 neofetch
mpkgs["procs"]="procs"                     # (https://github.com/dalance/procs) ps 대체
mpkgs["ripgrep"]="rg"                      # (https://github.com/BurntSushi/ripgrep) grep 대체
mpkgs["sd"]="sd"                           # (https://github.com/chmln/sd) sed 대체
mpkgs["termscp"]="termscp"                 # (https://github.com/veeso/termscp) scp,ftp 대체
mpkgs["termusic"]="termusic"               # (https://github.com/tramhao/termusic) terminal music player
mpkgs["termusic-server"]="termusic-server" # (https://github.com/tramhao/termusic) terminal music server
mpkgs["tokei"]="tokei"                     # (https://github.com/XAMPPRocky/tokei) 코드 통계
mpkgs["ttysvr"]="ttysvr"                   # (https://github.com/cxreiff/ttysvr) screen saver
mpkgs["typos-cli"]="typos"                 # (https://github.com/crate-ci/typos) 오타 체크
mpkgs["whome"]="whome"                     # (https://github.com/ardaku/whoami) whoami 대체
mpkgs["ytop"]="ytop"                       # (https://github.com/cjbassi/ytop) top,htop 대체
mpkgs["zellij"]="zellij"                   # (https://github.com/zellij-org/zellij) tmux 대체
mpkgs["zenith"]="zenith"                   # (https://github.com/bvaisvil/zenith) top,htop 대체
mpkgs["zoxide"]="zoxide"                   # (https://github.com/ajeetdsouza/zoxide) cd command 대체
# brew 로 설치해보기
#if [[ $(uname) == 'Darwin' ]]; then
#    for p in ${pkgs}; do
#        brew install $p
#    done
#fi

install_pkgs=""
already_installed_pkgs_by_brew=""
for pkg_name in "${!mpkgs[@]}"; do
    pkg_binary_name=${mpkgs[$pkg_name]}
    # echo $pkg_binary_name
    # brew 로 설치된 패키지는 cargo 로 설치 하지 않는 로직
    if [[ $(uname) == 'Darwin' ]]; then
        if [[ $(type -a $pkg_binary_name | grep -iE "/local/bin/|/homebrew/bin/") == *"$pkg_binary_name"* ]]; then
            already_installed_pkgs_by_brew+="$pkg_name "
            continue
        fi
    fi
    install_pkgs+="$pkg_name "
done
echo "install_pkgs=$install_pkgs"
echo "already_installed_pkgs_by_brew=$already_installed_pkgs_by_brew"

# cargo 가 제대로 동작하지 않는다면 다음과 같이 삭제 후 재설치한다.
#rustup uninstall stable && rustup install stable
rustup update
cargo install ${install_pkgs} --locked
cargo uninstall ${already_installed_pkgs_by_brew} 2>/dev/null

echo "-- show installed packages by cargo --"
cargo install --list | awk 'NR%2==0 {print $1}'
