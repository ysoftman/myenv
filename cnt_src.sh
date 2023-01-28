#!/bin/bash

cntsrc() {
    # uniq 는 인접한 라인과 비교해 반복되는것은 필터링 시키기 때문에 sort 이후에 사용해야 한다.
    fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*" | sed -e "s/\.[^.]*$//" | sort | uniq | wc
}

cntsrcLevel() {
    cnt_easy=0
    cnt_medium=0
    cnt_hard=0
    cnt_no_level=0
    easy_files=()
    medium_files=()
    hard_files=()
    no_level_files=()
    for f in $(fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*"); do
        r=$(rg -i -N "Easy|Medium|Hard" --color=never --no-filename --max-count 1 ${f} | sd "^(# )"  "")
        if [[ $r == "Easy" ]]; then
            cnt_easy=$((cnt_easy+1))
            easy_files+=($f)
        elif [[ $r == "Medium" ]]; then
            cnt_medium=$((cnt_medium+1))
            medium_files+=($f)
        elif [[ $r == "Hard" ]]; then
            cnt_hard=$((cnt_hard+1))
            hard_files+=($f)
        else
            cnt_no_level=$((cnt_no_level+1))
            no_level_files+=($f)
        fi
    done
    echo "Easy Files"
    for f in ${easy_files[@]}; do
        echo ${f}
    done
    echo "Medium Files"
    for f in ${medium_files[@]}; do
        echo ${f}
    done
    echo "Hard Files"
    for f in ${hard_files[@]}; do
        echo ${f}
    done
    echo "No Level Files"
    for f in ${no_level_files[@]}; do
        echo ${f}
    done
    echo "Easy:" ${cnt_easy}
    echo "Medium:" ${cnt_medium}
    echo "Hard:" ${cnt_hard}
    echo "No Level:" ${cnt_hard}
}
