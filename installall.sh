#!/bin/bash

bash ./installcommon.sh
bash ./installpowerlinefont.sh
zsh ./installprezto.zsh
zsh ./installohmyzsh.zsh
bash ./installconfig.sh
bash ./installvimplugin.sh
bash ./installbypip.sh
if [[ $(uname) == 'Darwin' ]]; then
    bash ./installbybrew.sh
    bash ./install_mac_app.sh
fi
