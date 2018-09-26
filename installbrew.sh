#!/bin/bash
if [[ $(uname) != 'Darwin' ]]; then
    echo 'it is not mac system.'
    exit 0
fi
brew install bat