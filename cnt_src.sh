#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

cntsrc() {
    easy_files=()
    medium_files=()
    hard_files=()
    no_level_files=()

    ######################
    # grep, rg 은 멀티 결과 일때 디폴트로 -- 구분자를 추가한다.
    # https://learnbyexample.github.io/learn_gnugrep_ripgrep/context-matching.html
    # rg 는 --context-separator 로 변경할 수 있다.
    # ${files} 개수가 많아 에러 --> File name too long (os error 63)
    # files=$(fd --type file ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*")
    # headers=$(rg -i -N "Easy|Medium|Hard" --heading --color=never --context-separator="___" --max-count 1 -B 1 ${files} | sd "^(# )"  "")
    ######################

    echo "processing..."

    # 전체 파일에서 탐색 후 for 안에서 특정 파일 제외시키자.
    headers=$(rg -i -N "Easy|Medium|Hard" --heading --color=never --max-count 1 -B 1 | sd "^(# )" "" | sd '^\n' '___\n')
    # IFS(Internal Field Separator) 를 space(디폴트)면
    # headers 값들이 한줄로 한번에 처리되는데 이때 File name too long 에러가 발생한다.
    # IFS 를 newline 로해 파일 1개씩 처리되도록 해야 한다.
    IFS=$'\n'
    # 아니면 다음과 같이 파이프로 전달하고 read -r 로 읽어도 된다.
    # rg -i -N "Easy|Medium|Hard" --heading --color=never --max-count 1 -B 1 | sd "^(# )" "" | sd '^\n' '___\n' | while read -r h; do
    for h in $(echo $headers); do
        if [[ $h == "___" ]]; then
            file=""
            title=""
            level=""
            continue
        fi
        if [[ -z $file ]]; then
            file=$h
            continue
        elif [[ -z $title ]]; then
            title=$h
            continue
        else
            level=$h
        fi

        # 어차피 "Easy|Medium|Hard" 로 필터링돼서 ysoftman_* 은 별도 스킵 처리하지 않아도 된다.
        # if [[ $file == "ysoftman_"* ]]; then
        #     file=""
        #     title=""
        #     level=""
        #     continue
        # fi

        # echo $file
        # echo $title
        # echo $level
        if [[ $level == "Easy" ]]; then
            easy_files+=("${title} -> ${file}\n")
        elif [[ $level == "Medium" ]]; then
            medium_files+=("${title} -> ${file}\n")
        elif [[ $level == "Hard" ]]; then
            hard_files+=("${title} -> ${file}\n")
        else
            no_level_files+=("${title} -> ${file}\n")
        fi
        file=""
        title=""
        level=""
    done
    # IFS 원복
    IFS=' '

    printf "\n[Easy Level]\n"
    temp=$(echo "${easy_files[@]}" | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_easy=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    printf "\n[Medium Level]\n"
    temp=$(echo "${medium_files[@]}" | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_medium=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    printf "\n[Hard Level]\n"
    temp=$(echo "${hard_files[@]}" | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_hard=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    printf "\n[No Level]\n"
    temp=$(echo "${no_level_files[@]}" | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_nolevel=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo ""
    print_cyan_msg "$(printf "Easy\t: %3d (unique: %3d)" ${#easy_files} ${cnt_unique_easy})"
    print_yellow_msg "$(printf "Medium\t: %3d (unique: %3d)" ${#medium_files} ${cnt_unique_medium})"
    print_red_msg "$(printf "Hard\t: %3d (unique: %3d)" ${#hard_files} ${cnt_unique_hard})"
    printf "nolevel\t: %3d (unique: %3d)\n" ${#no_level_files} ${cnt_unique_nolevel}
    print_green_msg "$(printf "All\t: %3d (unique: %3d)" \
        ${#easy_files}+${#medium_files}+${#hard_files}+${#no_level_files} \
        $((cnt_unique_easy + cnt_unique_medium + cnt_unique_hard + ${#no_level_files})))"

    # 쉘에서 이 함수내에서 사용했던 변수들이 참조되지 않도록 한다.
    unset file
    unset title
    unset level
    unset easy_files
    unset medium_files
    unset hard_files
    unset no_level_files
    unset cnt_unique_easy
    unset cnt_unique_medium
    unset cnt_unique_hard
    unset cnt_unique_all
    unset temp
}
