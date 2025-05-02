#!/bin/bash

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install oh-my-posh
else
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi
