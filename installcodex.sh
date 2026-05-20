#!/bin/bash
# ysoftman personal settings for codex
# Codex CLI 관련 개인 설정 및 설명입니다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
CODEX_CONFIG="${CODEX_HOME}/config.toml"
CODEX_CONFIG_MARKER_BEGIN="# BEGIN myenv codex config"
CODEX_CONFIG_MARKER_END="# END myenv codex config"

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

# project path 등 민감 정보 빼고 설정
mkdir -p "${CODEX_HOME}"
touch "${CODEX_CONFIG}"

codex_config_block="$(mktemp)"
codex_config_without_block="$(mktemp)"
trap 'rm -f "${codex_config_block}" "${codex_config_without_block}"' EXIT

cat >"${codex_config_block}" <<EOF
${CODEX_CONFIG_MARKER_BEGIN}
model = "gpt-5.5"
# model_reasoning_effort = "low"
model_reasoning_effort = "medium"
model_reasoning_summary = "concise"
model_verbosity = "low"

[features]
fast_mode = true
goals = true

[tui]
theme = "catppuccin-mocha"
status_line = [
  "model-with-reasoning",
  "current-dir",
  "project-name",
  "git-branch",
  "run-state",
  "context-used",
  "five-hour-limit",
  "weekly-limit",
  "context-window-size",
  "used-tokens",
  "total-input-tokens",
  "total-output-tokens",
  "pull-request-number",
  "branch-changes",
  "task-progress",
  "fast-mode",
]
status_line_use_colors = true

[tui.keymap.global]
# zelij ctrl-t 탭 단축키와 겹쳐서 커스텀으로 추가
open_transcript = "ctrl-alt-o"

[notice]
fast_default_opt_out = true
${CODEX_CONFIG_MARKER_END}

EOF

if grep -Fq "${CODEX_CONFIG_MARKER_BEGIN}" "${CODEX_CONFIG}"; then
    echo "Codex 기본 설정을 갱신합니다..."
    awk \
        -v begin="${CODEX_CONFIG_MARKER_BEGIN}" \
        -v end="${CODEX_CONFIG_MARKER_END}" \
        '
        # 기존 설정에서 마커 블록(begin~end)을 제거하고
        # 그 외 라인만 출력한다.
        $0 == begin { skip = 1; next }   # 시작 마커: skip 켜기, 마커 라인은 출력 안 함
        $0 == end   { skip = 0; next }   # 종료 마커: skip 끄기, 마커 라인은 출력 안 함
        !skip       { print }            # skip 꺼진 상태일 때만 라인 출력
        ' \
        "${CODEX_CONFIG}" >"${codex_config_without_block}"
else
    echo "Codex 기본 설정을 추가합니다..."
    cp "${CODEX_CONFIG}" "${codex_config_without_block}"
fi

cat "${codex_config_block}" "${codex_config_without_block}" >"${CODEX_CONFIG}"

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
