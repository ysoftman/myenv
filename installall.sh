#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

bash ./installcommon.sh
bash ./installpowerlinefont.sh
bash ./installzshautosuggestions.sh
bash ./installzshcompletion.sh
bash ./installzshsyntaxhighlighting.sh
bash ./installohmyzsh.sh
zsh ./installprezto.zsh
bash ./installstarship.sh
bash ./installohmyposh.sh
bash ./installconfig.sh

if [[ $os_name == *"darwin"* ]]; then
    bash ./installbrew.sh
    bash ./installapp.sh
    bash ./installitermcolor.sh
elif [[ $os_name == *"linux"* ]]; then
    bash ./installnode.sh
elif [[ $os_name == *"android"* ]]; then
    bash ./installnerdfont.sh
    bash ./installtermuxstyle.sh
    bash ./installkubectl.sh
fi

# mac brew 로 설치되는 프로그램과 중복되지 않도록 하기 위해 installbrew 뒤에 오도록 한다.
bash ./installzsh.sh
bash ./installvim.sh
bash ./installvimplug.sh
bash ./installneovim.sh
bash ./installtmuxplugin.sh
bash ./installpip.sh
bash ./installfzf.sh
bash ./installgolang.sh
bash ./installgolangtools.sh
bash ./installrust.sh
bash ./installvscodesettings.sh
bash ./installvscodeextension.sh
bash ./installcargo.sh
bash ./installemojicli.sh
