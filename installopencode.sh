#!/bin/bash
# ysoftman personal settings for opencode
# OpenCode 관련 개인 설정 및 설명입니다.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
OPENCODE_CONFIG_DIR="${XDG_CONFIG_HOME}/opencode"
OPENCODE_CONFIG="${OPENCODE_CONFIG_DIR}/opencode.json"
ATLASSIAN_MCP_URL="https://mcp.atlassian.com/v1/mcp"

ensure_atlassian_mcp() {
    if [[ ! -f "${OPENCODE_CONFIG}" ]]; then
        echo "OpenCode 설정 파일이 없어 Atlassian MCP 설정을 스킵합니다."
        return
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "jq가 없어 Atlassian MCP 설정 자동 추가를 스킵합니다."
        echo "  ${OPENCODE_CONFIG}의 mcp.atlassian에 ${ATLASSIAN_MCP_URL}을 추가하세요."
        return
    fi

    if jq -e --arg url "${ATLASSIAN_MCP_URL}" '.mcp.atlassian.type == "remote" and .mcp.atlassian.url == $url' "${OPENCODE_CONFIG}" >/dev/null 2>&1; then
        echo "Atlassian MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
        return
    fi

    echo "Atlassian MCP 서버 설정을 추가합니다..."
    local tmp_file
    tmp_file="$(mktemp)"
    if jq --arg url "${ATLASSIAN_MCP_URL}" '.mcp = (.mcp // {}) | .mcp.atlassian = {"type": "remote", "url": $url, "enabled": true}' "${OPENCODE_CONFIG}" >"${tmp_file}"; then
        cat "${tmp_file}" >"${OPENCODE_CONFIG}"
        rm -f "${tmp_file}"
        echo "완료. OpenCode 실행 후 MCP OAuth 안내가 나오면 로그인하세요."
    else
        rm -f "${tmp_file}"
        echo "OpenCode 설정 파일을 JSON으로 파싱할 수 없어 Atlassian MCP 설정을 스킵합니다." >&2
    fi
}

# opencode 설치
if command -v opencode >/dev/null 2>&1; then
    echo "OpenCode가 이미 설치되어 있습니다: $(command -v opencode)"
    opencode --version || true
else
    echo "OpenCode를 설치합니다..."
    if command -v bun >/dev/null 2>&1; then
        bun install -g opencode-ai
    else
        echo "bun이 필요합니다. 먼저 bun을 설치하세요." >&2
        exit 1
    fi
fi

# mcp 설치
# 인증은 OpenCode 실행 후 MCP OAuth 안내 또는 /connect에서 진행
ensure_atlassian_mcp

echo "모든 설치가 완료되었습니다."
echo ""
echo "로그인/모델 설정:"
echo "  opencode"
echo "  /connect"
echo "  /models"
echo ""
echo "로컬 LLM 사용 시:"
echo "  ollama serve"
echo "  opencode --model ollama/qwen3-coder:latest"
