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
    # headers=$(rg -i -N "Easy|Medium|Hard" --color=never --context-separator="___" --max-count 1 -B 1 ${files} | sd "^(# )"  "")
    ######################

    # 전체 파일에서 탐색 후 for 안에서 특정 파일 제외시키자.
    headers=$(rg -i -N "Easy|Medium|Hard" --color=never --max-count 1 -B 1 | sd "^(# )"  "" | sd '^\n' '___\n')
    echo "processing..."
    # IFS(Internal Field Separator) 를 space(디폴트)가 아닌 newline 으로 구분
    IFS=$'\n'
    for h in $(echo $headers)   ; do
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

    echo "\n[Easy Level]"
    temp=$(echo ${easy_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_easy=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[Medium Level]"
    temp=$(echo ${medium_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_medium=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[Hard Level]"
    temp=$(echo ${hard_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}
    cnt_unique_hard=$(echo $temp | awk '{print $1}' | uniq | wc | awk '{print $1}')

    echo "\n[No Level]"
    temp=$(echo ${no_level_files[@]} | sort -h | sd "^ " "" | sed 1d)
    echo ${temp}

    echo ""
    echo "${cyan}Easy: ${#easy_files} (unique: ${cnt_unique_easy}) ${reset_color}"
    echo "${yellow}Medium: ${#medium_files} (unique: ${cnt_unique_medium}) ${reset_color}"
    echo "${red}Hard: ${#hard_files} (unique: ${cnt_unique_hard}) ${reset_color}"
    echo "no level: ${#no_level_files}"
    echo ""

    # uniq 는 인접한 라인과 비교해 반복되는것은 필터링 시키기 때문에 sort 이후에 사용해야 한다.
    cnt_unique_all=$(echo $files | sed -e "s/\.[^.]*$//" | sort | uniq | wc | awk '{print $1}')
    echo "${green}All(unique): ${cnt_unique_all} ${reset_color}"
}
