#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

cntsrc() {
    easy_files=()
    medium_files=()
    hard_files=()
    no_level_files=()

    files=$(fd ".go|.cpp|.c|.sh|.sql" --exclude="ysoftman_*")

    # ${files} 개수가 많아 에러 --> File name too long (os error 63)
    ######################
    # grep, rg 은 멀티 결과 일때 디폴트로 -- 구분자를 추가한다.
    # https://learnbyexample.github.io/learn_gnugrep_ripgrep/context-matching.html
    # rg 는 --context-separator 로 변경할 수 있다.
    # headers=$(rg -i -N "Easy|Medium|Hard" --heading --color=never --context-separator="___" --max-count 1 -B 1 ${files} | sd "^(# )"  "")
    ######################

    # 전체 파일에서 탐색 후 for 안에서 특정 파일 제외시키자.
    headers=$(rg -i -N "Easy|Medium|Hard" --heading --color=never --max-count 1 -B 1 | sd "^(# )" "" | sd '^\n' '___\n')
    echo "processing..."
    # IFS(Internal Field Separator) 를 space(디폴트)면
    # headers 값들이 한줄로 한번에 처리되는데 이때 File name too long 에러가 발생한다.
    # IFS 를 newline 로해 파일 1개씩 처리되도록 해야 한다.
    IFS=$'\n'
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

    printf "\n[No Level]"
    temp=$(echo "${no_level_files[@]}" | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}

    echo ""
    print_cyan_msg "Easy: ${#easy_files} (unique: ${cnt_unique_easy})"
    print_yellow_msg "Medium: ${#medium_files} (unique: ${cnt_unique_medium})"
    print_red_msg "Hard: ${#hard_files} (unique: ${cnt_unique_hard})"
    echo "no level: ${#no_level_files}"
    echo ""

    # uniq 는 인접한 라인과 비교해 반복되는것은 필터링 시키기 때문에 sort 이후에 사용해야 한다.
    cnt_unique_all=$(echo $files | sed -e "s/\.[^.]*$//" | sort | uniq | wc | awk '{print $1}')
    print_green_msg "All(unique): ${cnt_unique_all}"

    # 쉘에서 이 함수내에서 사용했던 변수들이 참조되지 않도록 한다.
    unset files
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
