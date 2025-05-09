#!/bin/bash

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install starship
else
    curl -sS https://starship.rs/install.sh | sh
fi

export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p ${XDG_CONFIG_HOME}
[ -h ${XDG_CONFIG_HOME}/starship.toml ] && unlink ${XDG_CONFIG_HOME}/starship.toml
[ -f ${XDG_CONFIG_HOME}/starship.toml ] && mv -fv ${XDG_CONFIG_HOME}/starship.toml ${XDG_CONFIG_HOME}/starship.toml.bak
[ -d ${XDG_CONFIG_HOME} ] && ln -sfv ${PWD}/starship/starship.toml ${XDG_CONFIG_HOME}/starship.toml
