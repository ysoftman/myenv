#!/bin/bash
if which dosbox; then
    dosbox --args -conf dosbox.conf
else
    open -a DOSBox --args -conf dosbox.conf
fi
