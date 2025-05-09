#!/bin/bash

os_name=$(uname | tr '[:upper:]' '[:lower:]')
if [[ $os_name == *"darwin"* ]]; then
    brew install oh-my-posh
else
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi

export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p ${XDG_CONFIG_HOME}
[ -h ${XDG_CONFIG_HOME}/ysoftman.omp.toml ] && unlink ${XDG_CONFIG_HOME}/ysoftman.omp.toml
[ -f ${XDG_CONFIG_HOME}/ysoftman.omp.toml ] && mv -fv ${XDG_CONFIG_HOME}/ysoftman.omp.toml ${XDG_CONFIG_HOME}/ysoftman.omp.toml.bak
[ -d ${XDG_CONFIG_HOME} ] && ln -sfv ${PWD}/oh-my-posh/ysoftman.omp.toml ${XDG_CONFIG_HOME}/ysoftman.omp.toml
