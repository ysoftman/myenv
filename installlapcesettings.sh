#!/bin/bash
if [ $(uname) == 'Darwin' ]; then
    ln -sf ./lapce_settings/keymaps.toml ~/Library/Application\ Support/dev.lapce.Lapce-Stable/keymaps.toml
    ln -sf ./lapce_settings/settings.toml ~/Library/Application\ Support/dev.lapce.Lapce-Stable/settings.toml
else
    echo 'unknown system'
    exit 1
fi
