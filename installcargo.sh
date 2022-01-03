#!/bin/bash

# rust 버전업
rustup update

# https://github.com/ogham/exa
# https://github.com/Peltoche/lsd
# https://github.com/sharkdp/fd
# https://github.com/bootandy/dust
# https://github.com/imsnif/diskonaut
# https://github.com/chmln/sd
# https://github.com/BurntSushi/ripgrep
# https://github.com/sharkdp/bat
# https://github.com/dalance/procs
# https://github.com/ClementTsang/bottom
# https://github.com/imsnif/bandwhich
# https://github.com/sharkdp/hexyl
# https://github.com/sharkdp/hyperfine
cargo install -j 4 exa lsd fd-find du-dust diskonaut sd ripgrep bat procs btm bandwhich hexyl hyperfine

# 설치 확인
cargo install --list
