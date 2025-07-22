#!/bin/bash

# if command -v rustc >/dev/null 2>&1; then
#     echo "rust already installed in $(command -v rustc)"
#     exit 0
# fi

# rustup 을 설치해서 rustc/cargo 버전을 올려보자.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# cargo, rust-analyzer 등이 제대로 동작하지 않는다면 다음과 같이 삭제 후 재설치한다.
# rustup uninstall stable && rustup install stable
# ~/.rustup/toolchains/stable-aarch64-apple-darwin/bin 에 설치
rustup component add clippy rust-analyzer
# rust toolchains들을 ~/.cargo/bin/ 에서 링크를 생성하고 업데이트한다.
# cargo ⇒ rustup
# cargo-clippy ⇒ rustup
# cargo-fmt ⇒ rustup
# rls ⇒ rustup
# rust-analyzer ⇒ rustup
# rust-gdb ⇒ rustup
# rust-gdbgui ⇒ rustup
# rust-lldb ⇒ rustup
# rustc ⇒ rustup
# rustdoc ⇒ rustup
# rustfmt ⇒ rustup
rustup update
