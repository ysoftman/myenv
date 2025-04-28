#!/bin/bash

used_mem() {
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
