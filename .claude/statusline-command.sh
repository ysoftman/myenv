#!/bin/bash

# JSON 입력 읽기
input=$(cat)

# 사용자명, 호스트명, 현재 디렉토리 가져오기
username=$(whoami)
hostname=$(hostname -s)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# 색상 정의 (연속 코드는 반드시 합쳐서 사용)
RST='\033[0m'
BLUE='\033[34m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
BOLD_GREEN='\033[1;32m'

# 경로 축약 (HOME → ~)
display_path="$current_dir"
if [[ "$display_path" == "$HOME"* ]]; then
    display_path="~${display_path#"$HOME"}"
fi

# git 브랜치 및 상태 가져오기
git_info=""
if [ -d "$current_dir/.git" ] || git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(cd "$current_dir" && git -c advice.detachedHead=false rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ -n "$branch" ]; then
        git_info=" ${BOLD_GREEN}${branch}${RST}"

        # git 상태 확인
        git_status=$(cd "$current_dir" && git -c core.fileMode=false status --porcelain 2>/dev/null)

        if [ -n "$git_status" ]; then
            if echo "$git_status" | grep -q "^A"; then
                git_info="${git_info} ${GREEN}✚${RST}"
            fi
            if echo "$git_status" | grep -q "^ M\|^M"; then
                git_info="${git_info} ${YELLOW}✱${RST}"
            fi
            if echo "$git_status" | grep -q "^ D\|^D"; then
                git_info="${git_info} ${RED}✖${RST}"
            fi
            if echo "$git_status" | grep -q "^??"; then
                git_info="${git_info} ${MAGENTA}◼${RST}"
            fi
        fi
    fi
fi

# 상태 표시줄 출력 (printf %b 로 escape 코드 해석)
printf '%b' "${BLUE}${username}@${hostname}${RST} ${CYAN}${display_path}${RST}${git_info}"
