#!/usr/bin/env bash
# ysoftman
# tmux status-right 용 날씨 모듈 (wttr.in) — xamut/tmux-weather 플러그인 대체용.
#
# 플러그인 소스(~/.tmux/plugins/tmux-weather/scripts/weather.sh)를 직접 고치면 TPM 업데이트(prefix + U) 때 덮어써져 패치가 사라진다.
# 그래서 .tmux.conf 와 함께 myenv 레포에서 버전관리되는 이 스크립트로 대체하고, .tmux.conf 의 @catppuccin_weather_text 가 이 파일을 직접 호출한다.
#
# 사내 보안 프록시(Menlo Security 등)가 wttr.in 을 차단하면 HTTP 200 으로 "Web Page Blocked" HTML 페이지가 돌아온다.
# curl 종료코드만 보면 성공(0)이라 그대로 캐시·출력되어 상태줄에 HTML 이 노출된다. => 응답이 정상 날씨 문자열일 때만 캐시/출력한다.

location="$(tmux show-option -gqv @tmux-weather-location)"
format="$(tmux show-option -gqv @tmux-weather-format)"
format="${format:-1}"
units="$(tmux show-option -gqv @tmux-weather-units)"
case "$units" in
    m | u) ;;
    *) units="m" ;;
esac
interval_min="$(tmux show-option -gqv @tmux-weather-interval)"
interval_min="${interval_min:-15}"

# 정상 날씨 응답일 때만 참(0). 차단 HTML·빈 응답·비정상 길이는 거부.
is_valid_weather() {
    local v=$1
    [ -z "$v" ] && return 1
    case "$v" in
        *"<"* | *DOCTYPE* | *[Hh]tml* | *Blocked* | *"company policy"*) return 1 ;;
    esac
    # 정상 format 응답은 한 줄짜리 짧은 문자열. 100자 초과면 거부.
    [ "${#v}" -gt 100 ] && return 1
    return 0
}

update_interval=$((60 * interval_min))
now="$(date +%s)"
prev_time="$(tmux show-option -gqv @weather-previous-update-time)"
prev_time="${prev_time:-0}"
delta=$((now - prev_time))

# 캐시 만료 시에만 재요청 (wttr.in 부하/요청제한 최소화).
if [ "$delta" -ge "$update_interval" ]; then
    value="$(curl -s --max-time 5 "https://wttr.in/${location}?${units}&format=${format}" | sed 's/[[:space:]]km/km/g')"
    if is_valid_weather "$value"; then
        tmux set-option -g @weather-previous-update-time "$now"
        tmux set-option -g @weather-previous-value "$value"
    fi
fi

# 줄바꿈 없이 출력 (status-right 한 줄 유지).
printf '%s' "$(tmux show-option -gqv @weather-previous-value)"
