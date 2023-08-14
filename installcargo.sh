#!/bin/sh

# rustup 을 설치해서 rustc/cargo 버전을 올려보자.
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# cargo 가 제대로 동작하지 않는다면 다음과 같이 삭제 후 재설치한다.
#rustup uninstall stable && rustup install stable

cargo install bandwhich bat bottom diskonaut du-dust exa fd-find hello_cargo hexyl hyperfine lsd procs ripgrep rust_grep sd zellij git-delta
