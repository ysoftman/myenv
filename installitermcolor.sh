#!/bin/bash

if [ ! -d "iterm-colors" ]; then
    git clone https://github.com/mbadolato/iTerm2-Color-Schemes
else
    echo "iterms-colors already exist."
fi

iTerm2-Color-Schemes/tools/import-scheme.sh iTerm2-Color-Schemes/schemes/*
rm -rf iTerm2-Color-Schemes
