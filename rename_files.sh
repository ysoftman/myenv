#!/bin/bash
help_rename_files() {
    cat << zzz
rename (*.go) snakecase to kebabcase
ex) rename_files .go kebab

rename (*.go) kebabcase to snakecase
ex) rename_files .go snake
zzz
}

rename_files() {
    if [[ $# != 2 ]]; then
        help_rename_files
        return 1
    fi

    if [[ $2 != 'snake' ]] && [[ $2 != 'kebab' ]]; then
        echo 'wrong case!!!'
        help_rename_files
        return 2
    fi
    # echo $1
    # echo $2
    # IFS(Internal Field Separator) 를 space(디폴트)면
    # fd 결과 파일들이 한줄로 한번에 처리되는데 이때 File name too long 에러가 발생한다.
    # IFS 를 newline 로해 파일 1개씩 처리되도록 해야 한다.
    IFS=$'\n'
    for from in $(fd $1$); do
        if [[ $2 == 'snake' ]]; then
            to=$(echo $from | sed s/-/_/g)
        elif [[ $2 == 'kebab' ]]; then
            to=$(echo $from | sed s/_/-/g)
        fi
        if [[ $from != $to ]]; then
            mv -v $from $to;
        fi
    done
    IFS=' '
}
