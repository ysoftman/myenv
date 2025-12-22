#!/bin/bash

gh_cmd=$(command -v gh 2>/dev/null)
if [ -z $gh_cmd ]; then
    os_name=$(uname -o | tr '[:upper:]' '[:lower:]')
    if [[ $os_name == *"darwin"* ]]; then
        brew install gh
    else
        echo "can't find gh(github cli)"
        exit 1
    fi
fi

gh extension install leereilly/gh-yule-log
gh extension install dlvhdr/gh-dash
gh extension install kawarimidoll/gh-graph
