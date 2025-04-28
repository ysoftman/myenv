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
