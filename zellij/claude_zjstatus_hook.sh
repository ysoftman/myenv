#!/usr/bin/env bash
# 인자 없음: Claude Code hook. 세션별 상태 파일("<proj> <working|idle|blocked>")을 쓴다.
# render: zjstatus command_claude 위젯(rendermode dynamic). 상태 파일을 아이콘으로 출력한다. ~/.claude/sessions 에 없는(죽은) 세션 파일은 지운다.
#   세션마다 "아이콘 프로젝트" 를 출력한다. working: 아이콘이 1초마다 $surface1 과 번갈아 깜박임, idle: 아이콘 색 고정, blocked(권한 대기): 빨간 아이콘
# shellcheck disable=SC2016  # $surface1 등은 zjstatus 색 변수라 리터럴로 출력한다.
dir=/tmp/claude-zjstatus
if [[ $1 == render ]]; then
    colors=('$peach' '$surface1')
    live=" $(jq -r '"\(.pid) \(.sessionId)"' ~/.claude/sessions/*.json 2>/dev/null | while read -r pid sid; do kill -0 "$pid" 2>/dev/null && printf '%s ' "$sid"; done)"
    sessions=''
    for f in "$dir"/*; do
        [[ -f $f ]] || continue
        if [[ ! -d ~/.claude/sessions || $live != *" ${f##*/} "* ]]; then
            rm -f "$f"
            continue
        fi
        read -r proj state <"$f"
        case $state in
            working) c=${colors[$(date +%s) % 2]} ;;
            blocked) c='$red' ;;
            *) c='$peach' ;;
        esac
        sessions+='#[bg=$bg0,fg='"$c"']󰚩 #[bg=$bg0,fg=$text]'"$proj "
    done
    [[ -n $sessions ]] || exit 0
    printf '%s' "$sessions"
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
