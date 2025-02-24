#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

grep_and_sed_help() {
    echo "ex) Replace apple with lemon in all files under the current path"
    print_yellow_msg "grep_and_sed apple lemon"
}

grep_and_sed() {
    from_str=$1
    to_str=$2
    if [[ $from_str == "" || $to_str == "" ]]; then
        grep_and_sed_help
        return
    fi
    #-l, --files-with-matches : print only paths(files)
    for file in $(rg -l $from_str); do
        sed -i '' "s/${from_str}/${to_str}/g" $file
    done
}
