#!/bin/bash
# ysoftman
# backup my settings

# backup my brew list and make install script
install_file="installbybrew.sh"
echo '#!/bin/bash' > ${install_file}
printf "brew install " >> ${install_file}
brew list | sort | tr '\n' ' ' >> ${install_file}

# backup my pip list and make install script
install_file="installbypip.sh"
echo '#!/bin/bash' > ${install_file}
echo 'sudo pip install --upgrade pip' >> ${install_file}
printf "sudo pip install " >> ${install_file}
pip list | sed -n '3,$p' | awk '{print $1}' | tr '\n' ' ' >> ${install_file}
# --upgrade 필요시에만 사용
# echo ' --upgrade' >> ${install_file}

# backup .ssh directory
# 보안사항으로 github 저장소에 올리면 안됨.
# mkdir -p .ssh
# cp -v ~/.ssh/* ./.ssh/

# backup hosts
# 보안사항으로 github 저장소에 올리면 안됨.
# cp -v /etc/hosts ./hosts

# backup vscode settings
mkdir -p vscode_settings
cp -v ~/Library/Application\ Support/Code/User/*.json ./vscode_settings/

# backup vscode extension and make install script
install_file="installvscodeextension.sh"
echo '#!/bin/sh' > ${install_file}
code --list-extensions | sed 's/^/code --install-extension /g' >> ${install_file}
