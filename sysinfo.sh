#!/bin/bash

mac_used_mem() {
    if ! command -v vm_stat >/dev/null 2>&1; then
        return
    fi
    # vm_stat 를 한 번만 호출해 모든 값을 한 스냅샷에서 추출한다.
    # 여러 번 호출하면 값이 어긋나거나 호출당 비용이 누적된다.
    # used = (anon - purgeable) + wired + compressed : Activity Monitor "Memory Used" 와 같은 공식
    # anon - purgeable : 파일 캐시와 버려도 되는(purgeable) 캐시를 제외한 앱 점유 메모리 (App Memory)
    # active 를 쓰면 파일 캐시가 섞이고 inactive 앱 메모리가 빠져 실제보다 작게 나온다
    vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
        /page size of/        { page = $8 }
        /Pages wired down/    { wired = $4; sub(/\./, "", wired) }
        /Pages purgeable/     { purgeable = $3; sub(/\./, "", purgeable) }
        /Anonymous pages/     { anon = $3; sub(/\./, "", anon) }
        /Pages occupied by compressor/ { compressed = $5; sub(/\./, "", compressed) }
        END {
            used = (anon - purgeable + wired + compressed) * page
            printf "%.1fGi used (%d%%)\n", used / 1024 / 1024 / 1024, used * 100 / total
        }
    '
}

mac_info() {
    source "colors.sh"

    if ! command -v system_profiler >/dev/null 2>&1; then
        return
    fi
    print_blue_msg "$(system_profiler SPHardwareDataType | sed -e 's/^[ \t]*//' -e '/^[[:space:]]*$/d' -e '/Hardware:/d' -e '/Hardware Overview:/d')"
    echo ""

    if ! command -v sw_vers >/dev/null 2>&1; then
        return
    fi
    print_green_msg "$(sw_vers)"
    echo ""

    if ! command -v sysctl >/dev/null 2>&1; then
        return
    fi
    print_yellow_msg "$(sysctl -a | rg -i --color=never machdep.cpu)"

    if ! command -v networksetup >/dev/null 2>&1; then
        return
    fi
    print_purple_msg "$(networksetup -listallhardwareports | sed -e '/VLAN Configurations/d' -e '/^==.*$/d')"
}
