#!/bin/bash
if [[ $(uname) != 'Darwin' ]]; then
    echo 'it is not mac system.'
    exit 0
fi

cp -fv ./vscode_settings/*.json ~/Library/Application\ Support/Code/User/
sh ./installvscodeextension.sh
