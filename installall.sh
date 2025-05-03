#!/bin/bash
bash ./installcommon.sh
bash ./installpowerlinefont.sh
bash ./installzshautosuggestions.sh
bash ./installzshcompletion.sh
bash ./installzshsyntaxhighlighting.sh
bash ./installohmyzsh.sh
zsh ./installprezto.zsh
bash ./installstarship.sh
bash ./installohmyposh.sh
bash ./installvim.sh
bash ./installtmuxplugin.sh
bash ./installconfig.sh
bash ./installpip.sh
bash ./installitermcolor.sh
bash ./installvscodesettings.sh
bash ./installcargo.sh
# 백업 수행시 installbrew.sh 를 변경하기 때문에서 이곳에서 체크한다.
if [[ $(uname) == 'Darwin' ]]; then
    bash ./installbrew.sh
    bash ./installapp.sh
fi
