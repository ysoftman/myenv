#!/bin/bash
# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install lsd
cargo install --git https://github.com/Peltoche/lsd.git --branch master
