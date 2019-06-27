#!/bin/bash
# The ycmd server SHUT DOWN (restart with :YcmRestartServer)" 메시지가 발생하는 경우
cd ${HOME}/.vim/plugged/youcompleteme/
git submodule update --init --recursive
python2 ./install.py
