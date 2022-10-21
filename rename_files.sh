#!/bin/bash
help_rename_files() {
    cat << zzz
rename (*.go) snakecase to kebabcase
ex) $0 .go kebab

rename (*.go) kebabcase to snakecase
ex) $0 .go snake
zzz
}

rename_files() {
    if [[ $# != 2 ]]; then
        help_rename_files
        exit 1
    fi

    if [[ $2 != 'snake' ]] && [[ $2 != 'kebab' ]]; then
        echo 'wrong case!!!'
        help_rename_files
        exit 1
    fi
    # echo $1
    # echo $2

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
}
