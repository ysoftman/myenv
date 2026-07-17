#!/usr/bin/env bash

# 숫자 로케일만 C로 고정 (comma-decimal 로케일에서 printf %f 깨짐 방지)
# LC_ALL=C는 금지: ${var:0:n} 슬라이싱이 바이트 단위가 되어 멀티바이트 바(█) 깨짐
unset LC_ALL
export LC_NUMERIC=C

# JSON 입력 읽기
input=$(cat)

# 단일 jq 호출로 모든 필드 추출 (각 필드를 개별 라인으로 → mapfile)
# (tab-separated 사용 시 빈 필드가 collapse되는 문제 회피)
mapfile -t _fields < <(printf '%s' "$input" | jq -r '
    .workspace.current_dir // "",
    .model.display_name // "unknown",
    .context_window.used_percentage // 0,
    .context_window.context_window_size // 0,
    .cost.total_duration_ms // 0,
    .cost.total_cost_usd // 0,
    .context_window.current_usage.cache_read_input_tokens // 0,
    .context_window.current_usage.cache_creation_input_tokens // 0,
    .context_window.total_input_tokens // 0,
    .context_window.total_output_tokens // 0,
    .cost.total_lines_added // 0,
    .cost.total_lines_removed // 0,
    .rate_limits.five_hour.used_percentage // "",
    .rate_limits.five_hour.resets_at // "",
    .rate_limits.seven_day.used_percentage // "",
    .rate_limits.seven_day.resets_at // "",
    .effort.level // "",
    .thinking.enabled // false
')
current_dir="${_fields[0]}"
model_name="${_fields[1]}"
used_pct="${_fields[2]}"
context_size="${_fields[3]}"
duration_ms="${_fields[4]}"
cost_usd="${_fields[5]}"
cache_read="${_fields[6]}"
cache_write="${_fields[7]}"
total_input="${_fields[8]}"
total_output="${_fields[9]}"
lines_added="${_fields[10]}"
lines_removed="${_fields[11]}"
rl_5h_pct="${_fields[12]}"
rl_5h_reset="${_fields[13]}"
rl_7d_pct="${_fields[14]}"
rl_7d_reset="${_fields[15]}"
effort_level="${_fields[16]}"
thinking_enabled="${_fields[17]}"

# 세션 시간 계산
duration_s=$((duration_ms / 1000))
duration_h=$((duration_s / 3600))
duration_m=$(((duration_s % 3600) / 60))
duration_sec=$((duration_s % 60))
if [ "$duration_h" -gt 0 ]; then
    session_time="${duration_h}h${duration_m}m"
else
    session_time="${duration_m}m${duration_sec}s"
fi

# 색상 정의 (256-color, ANSI-C quoting → %s로 출력 가능)
RST=$'\033[0m'
C_RED=$'\033[38;5;203m'
C_ORANGE=$'\033[38;5;209m'
C_YELLOW=$'\033[38;5;221m'
C_GREEN=$'\033[38;5;114m'
C_CYAN=$'\033[38;5;80m'
C_BLUE=$'\033[38;5;75m'
C_INDIGO=$'\033[38;5;105m'
C_VIOLET=$'\033[38;5;177m'
C_PINK=$'\033[38;5;211m'
# git 상태 아이콘용
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'

username="${C_RED}${USER:-$(whoami)}${RST}"

# 경로 축약 (HOME → ~)
display_path="$current_dir"
if [[ "$display_path" == "$HOME"* ]]; then
    display_path="~${display_path#"$HOME"}"
fi
display_path="${C_CYAN}${display_path}${RST}"

# git 브랜치/상태 (output cap + bash glob 매칭)
git_info=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$current_dir" -c advice.detachedHead=false rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_info="${C_YELLOW}${branch}${RST}"
        # 4KB cap: 거대한 dirty tree에서도 statusline 렌더링 지연을 막음
        git_status=$(git -C "$current_dir" -c core.fileMode=false status --porcelain --no-renames 2>/dev/null | head -c 4096)
        if [ -n "$git_status" ]; then
            gs=$'\n'"$git_status"
            [[ "$gs" == *$'\n'A* ]] && git_info="${git_info} ${GREEN}✚${RST}"
            [[ "$gs" == *$'\nM'* || "$gs" == *$'\n M'* ]] && git_info="${git_info} ${YELLOW}✱${RST}"
            [[ "$gs" == *$'\nD'* || "$gs" == *$'\n D'* ]] && git_info="${git_info} ${RED}✖${RST}"
            [[ "$gs" == *$'\n'"??"* ]] && git_info="${git_info} ${MAGENTA}◼${RST}"
        fi
    fi
fi

# 프로그레스바 (pre-built 문자열 슬라이싱)
BAR_FULL="██████████"
BAR_HOLLOW="░░░░░░░░░░"
make_bar() {
    local pct=$1
    [ "$pct" -gt 100 ] && pct=100
    [ "$pct" -lt 0 ] && pct=0
    local filled=$((pct * 10 / 100))
    local empty=$((10 - filled))

    if [ "$pct" -ge 80 ]; then
        BAR_COLOR="$RED"
    elif [ "$pct" -ge 50 ]; then
        BAR_COLOR="$YELLOW"
    else
        BAR_COLOR="$GREEN"
    fi
    BAR_FILLED="${BAR_FULL:0:filled}"
    BAR_EMPTY="${BAR_HOLLOW:0:empty}"
}

# 토큰수 K/M 변환 (bash 정수 산술만 사용, bc 없음)
fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        echo "$((n / 1000000)).$(((n % 1000000) / 100000))M"
    elif [ "$n" -ge 1000 ]; then
        echo "$((n / 1000)).$(((n % 1000) / 100))K"
    else
        echo "$n"
    fi
}

# 잔여 초 포맷 (음수/0이면 빈 문자열 반환 → caller가 표시 생략)
fmt_remaining() {
    local sec=$1
    local mode=$2
    if [ "$sec" -le 0 ]; then
        return
    fi
    local d=$((sec / 86400))
    local h=$(((sec % 86400) / 3600))
    local m=$(((sec % 3600) / 60))
    if [ "$mode" = "dh" ]; then
        if [ "$d" -gt 0 ]; then
            echo "${d}d${h}h"
        else
            echo "${h}h${m}m"
        fi
    else
        if [ "$h" -gt 0 ]; then
            echo "${h}h${m}m"
        else
            echo "${m}m"
        fi
    fi
}

# context 바 (used_percentage는 소수로 올 수 있음 → 반올림)
used_pct=$(printf '%.0f' "$used_pct")
[ "$used_pct" -gt 100 ] && used_pct=100
make_bar "$used_pct"

context_fmt=$(fmt_tokens "$context_size")
total_in_fmt=$(fmt_tokens "$total_input")
total_out_fmt=$(fmt_tokens "$total_output")
cache_r_fmt=$(fmt_tokens "$cache_read")
cache_w_fmt=$(fmt_tokens "$cache_write")

# 비용: $1 이상은 소수 2자리, 미만은 4자리
int_part="${cost_usd%%.*}"
if [ "${int_part:-0}" -ge 1 ] 2>/dev/null; then
    cost_fmt=$(printf '%.2f' "$cost_usd")
else
    cost_fmt=$(printf '%.4f' "$cost_usd")
fi

token_info="${C_INDIGO}context[${BAR_COLOR}${BAR_FILLED}${RST}${BAR_EMPTY}${C_INDIGO}] ${BAR_COLOR}${used_pct}%${RST}${C_INDIGO}/${context_fmt}${RST} ${C_PINK}tokens[in:${total_in_fmt}/out:${total_out_fmt}]${RST}"
cache_info="${C_GREEN}cache[R:${cache_r_fmt}/W:${cache_w_fmt}]${RST}"

# model + effort + thinking
model_group="${C_VIOLET}${model_name}${RST}"

if [ -n "$effort_level" ]; then
    case "$effort_level" in
        low) eff_color="$C_GREEN" ;;
        medium) eff_color="$C_YELLOW" ;;
        high) eff_color="$C_ORANGE" ;;
        xhigh | max) eff_color="$C_RED" ;;
        *) eff_color="$RST" ;;
    esac
    model_group="${model_group} ${eff_color}effort:${effort_level}${RST}"
fi

# think는 effort/model과 색을 분리 (cyan)
if [ "$thinking_enabled" = "true" ]; then
    model_group="${model_group} ${C_CYAN}✦think${RST}"
fi

# Line 2: diff, session, cost, rate limits
line2=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    line2="${C_BLUE}+${lines_added}/-${lines_removed}${RST} "
fi
line2="${line2}${C_ORANGE}${session_time}${RST}"

printf -v now_epoch '%(%s)T' -1

fmt_rl_segment() {
    local label=$1 pct_raw=$2 reset=$3 mode=$4
    [ -z "$pct_raw" ] && return
    local pct
    pct=$(printf '%.0f' "$pct_raw")
    [ "$pct" -gt 100 ] && pct=100
    [ "$pct" -lt 0 ] && pct=0
    make_bar "$pct"
    local rem=""
    if [ -n "$reset" ]; then
        local r
        r=$(fmt_remaining $((reset - now_epoch)) "$mode")
        [ -n "$r" ] && rem=" $r"
    fi
    echo "${C_INDIGO}${label}[${BAR_COLOR}${BAR_FILLED}${RST}${BAR_EMPTY}${C_INDIGO}] ${BAR_COLOR}${pct}%${RST}${C_INDIGO}${rem}${RST}"
}

if [ -n "$rl_5h_pct" ]; then
    seg=$(fmt_rl_segment "5h" "$rl_5h_pct" "$rl_5h_reset" "hm")
    line2="${line2}  ${seg}"
fi
if [ -n "$rl_7d_pct" ]; then
    seg=$(fmt_rl_segment "7d" "$rl_7d_pct" "$rl_7d_reset" "dh")
    line2="${line2} ${seg}"
fi
line2="${line2}  ${C_YELLOW}\$${cost_fmt}${RST}"

# 출력 (공백 구분은 여기서 일괄 처리)
line1=("$username" "$display_path")
[ -n "$git_info" ] && line1+=("$git_info")
line1+=("$model_group" "$token_info" "$cache_info")
printf '%s' "${line1[*]}"
if [ -n "$line2" ]; then
    printf '\n%s' "$line2"
fi
