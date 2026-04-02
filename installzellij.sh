#!/bin/bash

# zellij 설치 확인
if ! command -v zellij &>/dev/null; then
    echo "zellij 가 설치되어 있지 않습니다. brew install zellij 로 설치하세요."
    exit 1
fi

# zellij 버전 확인 (0.40+)
ZELLIJ_VERSION=$(zellij --version | awk '{print $2}')
ZELLIJ_MAJOR=$(echo "$ZELLIJ_VERSION" | cut -d. -f1)
ZELLIJ_MINOR=$(echo "$ZELLIJ_VERSION" | cut -d. -f2)
if [ "$ZELLIJ_MAJOR" -eq 0 ] && [ "$ZELLIJ_MINOR" -lt 40 ]; then
    echo "zellij 0.40+ 이 필요합니다. 현재 버전: $ZELLIJ_VERSION"
    exit 1
fi

# https://github.com/stanislc/zellij-claude-teams
# claude code team mode 에서 tmux 대신 zellij 을 사용할 수 있도록 tmux 호출을 가로채 zellij 로 라우팅하는 shim
# zellij 버전업이 되면 동작 안하는 이슈등 불편해서 설치하지 않음
