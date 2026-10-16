#!/usr/bin/env bash
# zjstatus command_status 위젯(rendermode dynamic). AI 세션(claude/codex/gemini/agy/crush/opencode)과 cpu/mem/disk/user 를 색 태그와 함께 출력한다.
# zjstatus 는 탭마다 따로 돌고 결과가 오기 전까지 render 마다 명령을 다시 띄워, 탭 전환이 몰리면 보안 에이전트(exec 검사) CPU 가 폭주한다.
# 그래서 초마다 한 번만 실제로 계산하고 나머지 호출은 캐시를 builtin 으로만 출력한다. mac.kdl 에서 source(.) 로 불러 bash 하나만 띄운다.
# shellcheck disable=SC2016  # $bg0 등은 zjstatus 색 변수라 리터럴로 출력한다.
d=${BASH_SOURCE[0]%/*}
out=/tmp/status-zjstatus.out
stamp=/tmp/status-zjstatus.t
now=${EPOCHSECONDS:-$(date +%s)}
read -r t 2>/dev/null <"$stamp"
if [[ $t != "$now" ]]; then
    echo "$now" >"$stamp"
    # top 은 1초 이상 걸려 즉시 끝나는 ps %cpu 합산을 코어 수로 나눈다.
    cpu=$(ps -A -o %cpu= | awk -v n="$(sysctl -n hw.ncpu)" '{s+=$1} END {print int(s/n+0.5) "%"}')
    # mac_used_mem: cache/buffer 를 제외한 사용 메모리. "...Gi used (NN%)" 에서 NN% 만 남긴다.
    mem=$(source "$d/../sysinfo.sh" && mac_used_mem)
    mem=${mem##*(}
    mem=${mem%)*}
    # df 는 purgeable(정리 가능) 공간을 사용 가능 용량에 넣지 않아 Stats/Finder 보다 사용률이 약 3% 높게 나온다.
    disk=$(df -k / | awk 'NR==2 {print int(($2-$4)/$2*100+0.5) "%"}')
    {
        "$d"/claude_zjstatus_hook.sh render
        "$d"/codex_zjstatus_hook.sh render
        "$d"/gemini_zjstatus.sh
        "$d"/agy_zjstatus.sh
        "$d"/crush_zjstatus.sh
        "$d"/opencode_zjstatus.sh
        printf '%s' '#[bg=$bg0,fg=$red]#[bg=$red,fg=$crust] '"${cpu:--}"'#[bg=$bg0,fg=$red]'
        printf '%s' '#[bg=$bg0,fg=$green]#[bg=$green,fg=$crust] '"${mem:--}"'#[bg=$bg0,fg=$green]'
        printf '%s' '#[bg=$bg0,fg=$sky]#[bg=$sky,fg=$crust]󰋊 '"${disk:--}"'#[bg=$bg0,fg=$sky]'
        printf '%s' '#[bg=$bg0,fg=$flamingo]#[bg=$flamingo,fg=$crust]󰀄 '"${USER:--}"'#[bg=$bg0,fg=$flamingo]'
    } >"$out.$$" && mv -f "$out.$$" "$out"
fi
IFS= read -r s 2>/dev/null <"$out"
printf '%s' "$s"
