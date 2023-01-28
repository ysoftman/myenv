#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

cntsrc() {
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
            easy_files+=("${title} -> ${f}\n")
        elif [[ $level == "Medium" ]]; then
            medium_files+=("${title} -> ${f}\n")
        elif [[ $level == "Hard" ]]; then
            hard_files+=("${title} -> ${f}\n")
        else
            no_level_files+=("${title} -> ${f}\n")
        fi
        echo -n "."
    done
    echo "\n[Easy Files]"
    temp=$(echo ${easy_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_easy=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[Medium Files]"
    temp=$(echo ${medium_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_medium=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[Hard Files]"
    temp=$(echo ${hard_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_hard=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[No Level Files]"
    temp=$(echo ${no_level_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}

    echo ""
    echo "${cyan}Easy: ${#easy_files} (unique: ${cnt_unique_easy}) ${reset_color}"
    echo "${yellow}Medium: ${#medium_files} (unique: ${cnt_unique_medium}) ${reset_color}"
    echo "${red}Hard: ${#hard_files} (unique: ${cnt_unique_hard}) ${reset_color}"
    echo "no level: ${#no_level_files}"
    echo ""
    # uniq 는 인접한 라인과 비교해 반복되는것은 필터링 시키기 때문에 sort 이후에 사용해야 한다.
    echo "${green}All(unique):" $(fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*" | sed -e "s/\.[^.]*$//" | sort | uniq | wc | awk '{print $1}')${reset_color}
}
