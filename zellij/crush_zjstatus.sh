#!/usr/bin/env bash
# zjstatus command_status 위젯(status_zjstatus.sh)의 crush 부분. 실행 중인 crush 프로세스의 cwd 이름을 상태 아이콘과 함께 출력한다. 프로세스가 없으면 출력 없음.
#   crush hook 은 PreToolUse 뿐이라 턴 종료를 알 수 없어, 직전 샘플 이후 초당 CPU 시간이 busy 를 넘으면 working 으로 본다(작업 중 spinner 가 TUI 를 계속 다시 그린다).
#   마지막으로 넘은 뒤 4초까지는 working 유지. 탭마다 도는 zjstatus 가 같은 샘플 파일을 쓰므로 2초가 안 된 샘플이면 그 결과를 재사용한다.
#   세션마다 "아이콘 프로젝트" 를 출력한다. working: 아이콘이 1초마다 $surface1 과 번갈아 깜박임, idle: 아이콘 색 고정
# shellcheck disable=SC2016  # $bg0 등은 zjstatus 색 변수라 리터럴로 출력한다.
busy=0.04 # 초당 CPU 초. 측정: 작업 중 0.08~0.16, 대기 0.00~0.01
cache=/tmp/crush-zjstatus.cpu
pids=$(ps -axo pid=,args= | awk '$2 ~ /(^|\/)crush$/ { print $1 }' | paste -sd, -)
if [[ -z $pids ]]; then
    rm -f "$cache"
    exit 0
fi
# cwd 이름별 "<proj> <working|idle>" 출력. cache 줄: "t <epoch>", "<pid> <누적 CPU 초>", "s <proj> <상태>", "b <proj> <마지막 busy epoch>"
states=$({
    lsof -a -d cwd -p "$pids" -Fpn 2>/dev/null
    ps -o pid=,time= -p "$pids" | sed 's/^ */c /'
} | awk -v now="$(date +%s)" -v f="$cache" -v tmp="$cache.$$" -v busy="$busy" '
    /^p/ { p = substr($0, 2); next }
    /^n/ { sub(/.*\//, ""); name[p] = $0; next }
    $1 == "c" { n = split($3, a, ":"); c = 0; for (i = 1; i <= n; i++) c = c * 60 + a[i]; cpu[$2] = c }
    END {
        while ((getline l < f) > 0) {
            split(l, a, " ")
            if (a[1] == "t") pt = a[2]
            else if (a[1] == "s") old[a[2]] = a[3]
            else if (a[1] == "b") lb[a[2]] = a[3]
            else pc[a[1]] = a[2]
        }
        if (pt != "" && now - pt < 2) {
            for (k in old) print k, old[k]
            exit
        }
        print "t", now > tmp
        for (k in cpu) {
            print k, cpu[k] > tmp
            if (!(k in name)) continue
            seen[name[k]] = 1
            if (pt != "" && (k in pc)) rate[name[k]] += (cpu[k] - pc[k]) / (now - pt)
        }
        for (k in seen) {
            if (rate[k] > busy) lb[k] = now
            s = (k in lb) && now - lb[k] < 4 ? "working" : "idle"
            if (k in lb) print "b", k, lb[k] > tmp
            print "s", k, s > tmp
            print k, s
        }
        close(tmp)
        system("mv -f \"" tmp "\" \"" f "\"")
    }' | sort)
colors=('$pink' '$surface1')
out=''
while read -r proj s; do
    [[ -n $proj ]] || continue
    c='$pink'
    [[ $s == working ]] && c=${colors[$(date +%s) % 2]}
    out+='#[bg=$bg0,fg='"$c"']󰋑 #[bg=$bg0,fg=$text]'"$proj "
done <<<"$states"
printf '%s' "$out"
