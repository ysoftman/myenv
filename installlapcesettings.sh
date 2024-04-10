#!/bin/bash
if [ $(uname) == 'Darwin' ]; then
    cp -fv ./lapce_settings/*.toml ~/Library/Application\ Support/dev.lapce.Lapce-Stable/
else
    echo 'unknown system'
    exit 1
fi
