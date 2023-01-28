#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

cntsrc() {
    cnt_easy=0
    cnt_medium=0
    cnt_hard=0
    cnt_no_level=0
    easy_files=()
    medium_files=()
    hard_files=()
    no_level_files=()
    echo -n "processing"
    for f in $(fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*"); do
        header=$(rg -i -N "Easy|Medium|Hard" --color=never --no-filename --max-count 1 -B1 ${f} | sd "^(# )"  "")
        title=$(echo $header | head -1)
        level=$(echo $header | tail -1)
        if [[ $level == "Easy" ]]; then
            cnt_easy=$((cnt_easy+1))
            easy_files+=("${title} -> ${f}\n")
        elif [[ $level == "Medium" ]]; then
            cnt_medium=$((cnt_medium+1))
            medium_files+=("${title} -> ${f}\n")
        elif [[ $level == "Hard" ]]; then
            cnt_hard=$((cnt_hard+1))
            hard_files+=("${title} -> ${f}\n")
        else
            cnt_no_level=$((cnt_no_level+1))
            no_level_files+=("${title} -> ${f}\n")
        fi
        echo -n "."
    done
    echo "\n[Easy Files]"
    echo ${easy_files[@]} | sort -h | sd "^ " "" | sed 1d
    echo "\n[Medium Files]"
    echo ${medium_files[@]} | sort -h | sd "^ " "" | sed 1d
    echo "\n[Hard Files]"
    echo ${hard_files[@]} | sort -h | sd "^ " "" | sed 1d
    echo "\n[No Level Files]"
    echo ${no_level_files[@]} | sort -h | sd "^ " "" | sed 1d

    echo "${cyan}Easy:" ${cnt_easy}${reset_color}
    echo "${yellow}Medium:" ${cnt_medium}${reset_color}
    echo "${red}Hard:" ${cnt_hard}${reset_color}
    echo "no level:" ${cnt_no_level}

    # uniq 는 인접한 라인과 비교해 반복되는것은 필터링 시키기 때문에 sort 이후에 사용해야 한다.
    echo "All(unique problems):" $(fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*" | sed -e "s/\.[^.]*$//" | sort | uniq | wc | awk '{print $1}')
}
