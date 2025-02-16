#!/bin/bash

if [ ! -d "$myenv_path/emoji-cli" ]; then
    git clone https://github.com/b4b4r07/emoji-cli $myenv_path/emoji-cli
fi
