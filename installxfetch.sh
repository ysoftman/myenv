#!/bin/bash

# https://github.com/xfetch-cli/xfetch
curl -fsSL https://raw.githubusercontent.com/xfetch-cli/xfetch/main/install.sh | bash

~/.local/bin/xfetch plugin install animate-logo

mkdir -p ~/.config/xfetch/logos
for dir in assets configs; do
    curl -fsSL "https://api.github.com/repos/xfetch-cli/plugins/contents/plugins/animate-logo/${dir}" |
        grep -o '"download_url": *"[^"]*\.txt"' | grep -o 'https[^"]*' |
        while read -r url; do
            curl -fsSL "$url" -o ~/.config/xfetch/logos/"$(basename "$url")"
        done
done
