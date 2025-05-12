#!/bin/bash

if command -v rustc >/dev/null 2>&1; then
    echo "rust already installed in $(command -v rustc)"
    exit 0
fi

# rustup 을 설치해서 rustc/cargo 버전을 올려보자.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
