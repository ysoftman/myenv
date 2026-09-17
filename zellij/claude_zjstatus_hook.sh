#!/usr/bin/env bash
# 인자 없음: Claude Code hook. 세션별 상태 파일("<proj> <working|idle|blocked>")을 쓴다.
# render: zjstatus command_claude 위젯(rendermode dynamic). 상태 파일을 아이콘으로 출력한다.
#   working: 노란 spinner(Claude Code 와 같은 프레임), idle: 초록 ●, blocked(권한 대기): 빨간 !
# shellcheck disable=SC2016  # $surface1 등은 zjstatus 색 변수라 리터럴로 출력한다.
dir=/tmp/claude-zjstatus
if [[ $1 == render ]]; then
    frames=(· ✢ ✳ ✶ ✻ ✽ ✻ ✶ ✳ ✢)
    spin=${frames[$(date +%s) % ${#frames[@]}]}
    out='#[bg=$bg0,fg=$peach]󰚩 '
    for f in "$dir"/*; do
        [[ -f $f ]] || continue
        read -r proj state <"$f"
        case $state in
            working) icon='#[bg=$bg0,fg=$yellow]'$spin ;;
            blocked) icon='#[bg=$bg0,fg=$red]!' ;;
            *) icon='#[bg=$bg0,fg=$green]●' ;;
        esac
        out+='#[bg=$bg0,fg=$text]'"$proj$icon "
    done
    out+=' '
    printf '%s' "${out% }"
    exit 0
fi
in=$(cat)
ev=$(jq -r .hook_event_name <<<"$in")
sid=$(jq -r .session_id <<<"$in")
proj=$(basename "$(jq -r .cwd <<<"$in")")
mkdir -p "$dir"
case $ev in
    UserPromptSubmit | PreToolUse | PostToolUse) s=working ;;
    SessionStart | Stop) s=idle ;;
    Notification)
        s=idle
        [[ $(jq -r .notification_type <<<"$in") == permission_prompt ]] && s=blocked
        ;;
    SessionEnd)
        rm -f "$dir/$sid"
        exit 0
        ;;
    *) exit 0 ;;
esac
echo "$proj $s" >"$dir/.$sid" && mv -f "$dir/.$sid" "$dir/$sid"
