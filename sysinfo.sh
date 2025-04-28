#!/bin/bash

mac_used_mem() {
    if ! command -v vm_stat >/dev/null 2>&1; then
        return
    fi
    local PAGE_SIZE
    local WIRED
    local ACTIVE
    local COMPRESSED
    local USED
    PAGE_SIZE=$(vm_stat | grep "page size of" | awk '{print $8}')
    WIRED=$(vm_stat | grep "wired down" | awk '{print $4}' | sed 's/\.//')
    ACTIVE=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    COMPRESSED=$(vm_stat | grep "Pages occupied by compressor" | awk '{print $5}' | sed 's/\.//')
    USED=$(((WIRED + ACTIVE + COMPRESSED) * PAGE_SIZE / 1024 / 1024 / 1024))
    echo "${USED}Gi used"
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
