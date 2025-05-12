#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

bash ./installcommon.sh
bash ./installpowerlinefont.sh
bash ./installzsh.sh
bash ./installzshautosuggestions.sh
bash ./installzshcompletion.sh
bash ./installzshsyntaxhighlighting.sh
bash ./installohmyzsh.sh
zsh ./installprezto.zsh
bash ./installstarship.sh
bash ./installohmyposh.sh
bash ./installvim.sh
bash ./installvimplug.sh
bash ./installneovim.sh
bash ./installtmuxplugin.sh
bash ./installconfig.sh
bash ./installpip.sh
bash ./installgolangtools.sh
bash ./installitermcolor.sh
bash ./installvscodesettings.sh
bash ./installvscodeextension.sh
bash ./installcargo.sh
bash ./installfzf.sh
bash ./installemojicli.sh

if [[ $os_name == *"darwin"* ]]; then
    bash ./installbrew.sh
    bash ./installapp.sh
elif [[ $os_name == *"linux"* ]]; then
    bash ./installnode.sh
elif [[ $os_name == *"android"* ]]; then
    bash ./installnerdfont.sh
    bash ./installtermuxstyle.sh
fi
