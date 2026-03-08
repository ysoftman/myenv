#!/bin/bash

# zellij-tmux-shim 설치
# claude code team mode 에서 tmux 대신 zellij 을 사용할 수 있도록
# tmux 호출을 가로채 zellij 로 라우팅하는 shim
# 참고: https://github.com/stanislc/zellij-claude-teams
# 요구사항: zellij 0.40+, bash 3.2+

SHIM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim"
REPO_URL="https://github.com/stanislc/zellij-claude-teams.git"
CLONE_DIR="/tmp/zellij-claude-teams"
ZSHRC="$HOME/.zshrc"
MARKER="Zellij-tmux-shim"

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

# 이미 설치되어 있는 경우 업데이트
if [ -d "$SHIM_DIR" ]; then
    echo "기존 zellij-tmux-shim 을 제거하고 재설치합니다."
    rm -rf "$SHIM_DIR"
fi

# clone & install
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR" || exit 1
bash install.sh
cd - >/dev/null || exit 1
rm -rf "$CLONE_DIR"

# 설치 확인
if [ ! -f "$SHIM_DIR/activate.sh" ]; then
    echo "설치에 실패했습니다."
    exit 1
fi

echo ""
echo "설치 완료: $SHIM_DIR"
echo ""

# .zshrc 에 activation 스니펫 추가
if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
    echo ".zshrc 에 이미 설정이 추가되어 있습니다."
else
    cat >>"$ZSHRC" <<'SNIPPET'

# --- Zellij-tmux-shim (Claude Code agent teams in zellij) ---
if [[ -n "$ZELLIJ" ]]; then
    _shim="${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim/activate.sh"
    [[ -f "$_shim" ]] && source "$_shim"
    unset _shim
fi
SNIPPET
    echo ".zshrc 에 activation 설정을 추가했습니다."
fi

echo ""
echo "사용법:"
echo "  1. zellij 세션 시작: zellij"
echo "  2. shim 활성화 확인: which tmux → $SHIM_DIR/bin/tmux 이면 정상"
echo "  3. claude 실행 후 team mode 사용 시 teammate 가 zellij pane 으로 표시됨"
echo ""
echo "제거: cd /tmp && git clone $REPO_URL && cd zellij-claude-teams && bash install.sh --uninstall"
