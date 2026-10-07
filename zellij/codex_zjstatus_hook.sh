#!/usr/bin/env bash
# 인자 없음: Codex CLI hook(~/.codex/hooks.json). 세션별 상태 파일("<proj> <working|idle|blocked>")을 쓴다.
# render: zjstatus command_codex 위젯(rendermode dynamic). 실행 중인 codex(TUI/exec) 프로세스의 cwd 이름을 상태 아이콘과 함께 출력한다.
#   hook 은 첫 프롬프트 때부터 오고, TUI 를 꺼도 살아있는 app-server daemon 아래에서 돌며 SessionEnd 도 오지 않는다.
#   그래서 살아있는 codex 프로세스 cwd 와 이름이 맞지 않는 상태 파일은 지우고, 아직 상태 파일이 없는 프로세스는 idle 로 표시한다.
#   working: 노란 spinner, idle: 초록 ●, blocked(권한 대기): 빨간 !
# shellcheck disable=SC2016  # $surface1 등은 zjstatus 색 변수라 리터럴로 출력한다.
dir=/tmp/codex-zjstatus
if [[ $1 == render ]]; then
    frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    spin=${frames[$(date +%s) % ${#frames[@]}]}
    pids=$(ps -axo pid=,comm= | awk '!/app-server-daemon/ && /\/codex$/ {print $1}' | paste -sd, -)
    if [[ -z $pids ]]; then
        rm -f "$dir"/*
        exit 0
    fi
    live=" $(lsof -a -d cwd -p "$pids" -Fn 2>/dev/null | sed -n 's|^n.*/||p' | tr '\n' ' ')"
    out='#[bg=$bg0,fg=$sky]󰞷 '
    seen=' '
    for f in "$dir"/*; do
        [[ -f $f ]] || continue
        read -r proj state <"$f"
        if [[ $live != *" $proj "* ]]; then
            rm -f "$f"
            continue
        fi
        seen+="$proj "
        case $state in
            working) icon='#[bg=$bg0,fg=$yellow]'$spin ;;
            blocked) icon='#[bg=$bg0,fg=$red]!' ;;
            *) icon='#[bg=$bg0,fg=$green]●' ;;
        esac
        out+='#[bg=$bg0,fg=$text]'"$proj$icon "
    done
    for proj in $live; do
        [[ $seen == *" $proj "* ]] && continue
        seen+="$proj "
        out+='#[bg=$bg0,fg=$text]'"$proj"'#[bg=$bg0,fg=$green]● '
    done
    printf '%s' "$out"
    exit 0
fi
in=$(cat)
ev=$(jq -r .hook_event_name <<<"$in")
sid=$(jq -r .session_id <<<"$in")
proj=$(basename "$(jq -r .cwd <<<"$in")")
mkdir -p "$dir"
case $ev in
    UserPromptSubmit | PreToolUse | PostToolUse) s=working ;;
    SessionStart | Stop | Interrupt) s=idle ;;
    PermissionRequest) s=blocked ;;
    SessionEnd)
        rm -f "$dir/$sid"
        exit 0
        ;;
    *) exit 0 ;;
esac
echo "$proj $s" >"$dir/.$sid" && mv -f "$dir/.$sid" "$dir/$sid"
