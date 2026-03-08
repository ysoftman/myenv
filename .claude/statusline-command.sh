#!/bin/bash

# JSON 입력 읽기
input=$(cat)

# 사용자명, 호스트명, 현재 디렉토리 가져오기
username=$(whoami)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# 모델명 가져오기
model_name=$(echo "$input" | jq -r '.model.display_name // "unknown"')

# 토큰 사용량 가져오기
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# 세션 시간 가져오기
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
duration_s=$((duration_ms / 1000))
duration_h=$((duration_s / 3600))
duration_m=$(((duration_s % 3600) / 60))
duration_sec=$((duration_s % 60))
if [ "$duration_h" -gt 0 ]; then
    session_time="${duration_h}h${duration_m}m"
else
    session_time="${duration_m}m${duration_sec}s"
fi

# 비용 가져오기
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# 캐시 토큰 가져오기
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# 누적 토큰 가져오기
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# 코드 변경량 가져오기
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# 색상 정의 (항목마다 겹치지 않는 무지개 색상, 256-color)
RST='\033[0m'
C_RED='\033[38;5;203m'
C_ORANGE='\033[38;5;209m'
C_YELLOW='\033[38;5;221m'
C_GREEN='\033[38;5;114m'
C_CYAN='\033[38;5;80m'
C_BLUE='\033[38;5;75m'
C_INDIGO='\033[38;5;105m'
C_VIOLET='\033[38;5;177m'
C_PINK='\033[38;5;211m'
# git 상태 아이콘용
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'

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
        git_info=" ${C_YELLOW}${branch}${RST}"

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

# 프로그레스바 생성
bar_width=10
filled=$((used_pct * bar_width / 100))
empty=$((bar_width - filled))

# 사용률에 따른 색상 결정
if [ "$used_pct" -ge 80 ]; then
    bar_color="$RED"
elif [ "$used_pct" -ge 50 ]; then
    bar_color="$YELLOW"
else
    bar_color="$GREEN"
fi

# 프로그레스바 문자열 조합
bar_filled=""
for ((i = 0; i < filled; i++)); do
    bar_filled="${bar_filled}█"
done
bar_empty=""
for ((i = 0; i < empty; i++)); do
    bar_empty="${bar_empty}░"
done

# 토큰수를 K 단위로 변환하는 함수
fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        echo "$(echo "scale=1; $n / 1000000" | bc)M"
    elif [ "$n" -ge 1000 ]; then
        echo "$(echo "scale=1; $n / 1000" | bc)K"
    else
        echo "$n"
    fi
}

context_fmt=$(fmt_tokens "$context_size")
total_in_fmt=$(fmt_tokens "$total_input")
total_out_fmt=$(fmt_tokens "$total_output")
cache_r_fmt=$(fmt_tokens "$cache_read")
cache_w_fmt=$(fmt_tokens "$cache_write")

# 비용 포맷 (소수점 4자리)
cost_fmt=$(printf '%.4f' "$cost_usd")

token_info=" ${C_INDIGO}context[${bar_color}${bar_filled}${RST}${bar_empty}${C_INDIGO}] ${bar_color}${used_pct}%${RST}${C_INDIGO}/${context_fmt}${RST}"

# 캐시 정보
cache_info=" ${C_GREEN}cache[R:${cache_r_fmt}/W:${cache_w_fmt}]${RST}"

# 누적 토큰 정보
cumulative_info=" ${C_PINK}tokens[in:${total_in_fmt}/out:${total_out_fmt}]${RST}"

# 코드 변경 정보
diff_info=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    diff_info=" ${C_BLUE}+${lines_added}/-${lines_removed}${RST}"
fi

# 세션 시간
session_info=" ${C_ORANGE}${session_time}${RST}"

# 비용
cost_info=" ${C_YELLOW}\$${cost_fmt}${RST}"

# 상태 표시줄 출력 (printf %b 로 escape 코드 해석)
printf '%b' "${C_RED}${username}${RST} ${C_CYAN}${display_path}${RST}${git_info}${token_info}${cache_info}${cumulative_info}${diff_info}${session_info}${cost_info} ${C_VIOLET}${model_name}${RST}"
