#!/bin/bash

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install starship
else
    curl -sS https://starship.rs/install.sh | sh
fi
