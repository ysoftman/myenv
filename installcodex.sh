#!/bin/bash
# ysoftman personal settings for codex
# Codex CLI 관련 개인 설정 및 설명입니다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"

# codex cli 설치
if command -v codex >/dev/null 2>&1; then
    echo "Codex CLI가 이미 설치되어 있습니다: $(command -v codex)"
    codex --version
else
    echo "Codex CLI를 설치합니다..."
    if command -v bun >/dev/null 2>&1; then
        bun add -g @openai/codex
    elif command -v npm >/dev/null 2>&1; then
        npm install -g @openai/codex
    else
        echo "bun 또는 npm이 필요합니다. 먼저 Node.js/bun 환경을 설치하세요." >&2
        exit 1
    fi
fi

# codex 설정 링크
mkdir -p "${CODEX_HOME}"

# mcp 설치
# 인증은 codex mcp login atlassian 으로 진행
mcp_list="$(codex mcp list 2>&1 || true)"
if grep -q "atlassian" <<<"${mcp_list}"; then
    echo "Atlassian MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
else
    echo "Atlassian MCP 서버를 설치합니다..."
    codex mcp add atlassian --url https://mcp.atlassian.com/v1/mcp
    echo "완료. 필요 시 codex mcp login atlassian 으로 웹 로그인하세요."
fi

echo "모든 설치가 완료되었습니다."
