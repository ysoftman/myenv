#!/bin/bash

if [ ! -d "iterm-colors" ]; then
    git clone https://github.com/bahlo/iterm-colors
else
    echo "iterms-colors already exist."
fi
