#!/bin/bash
example() {
    cat << zzz
rename (*.go) snakecase to kebabcase
ex) $0 .go kebab

rename (*.go) kebabcase to snakecase
ex) $0 .go snake
zzz
}

if [ $# != 2 ]; then
    example
    exit 1
fi

if [ $2 != 'snake' ] && [ $2 != 'kebab' ]; then
    echo 'wrong case!!!'
    example
    exit 1
fi
# echo $1
# echo $2

files=$(fd $1$)
for from in $files; do
    if [ $2 == 'snake' ]; then
        to=$(echo $from | sed s/-/_/g)
    elif [ $2 == 'kebab' ]; then
        to=$(echo $from | sed s/_/-/g)
    fi
    if [[ $from != $to ]]; then
        mv -v $from $to;
    fi
done
