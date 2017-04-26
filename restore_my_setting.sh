#!/bin/bash
# ysoftman
# restore my settings

# git config
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global color.ui auto
git config --global core.editor vim
git config --global merge.tool vimdiff


sh ./installcommon.sh

zsh ./installprezto.zsh

if [[ $(uname) == 'Darwin' ]]; then
    sh ./installbybrew.sh
fi

sh ./installbypip.sh

cp -fv ./.bashrc ~/.bashrc
cp -fv ./.zshrc ~/.zshrc
cp -fv ./.vimrc ~/.vimrc

# 보안사항으로 실제 필요할때만 사용하자
# cp -fv ./.ssh/* ~/.ssh

# 보안사항으로 실제 필요할때만 사용하자
#sudo cp -fv hosts /etc/hosts

sh ./installvimplugin.sh

if [[ $(uname) == 'Darwin' ]]; then

    if [ -e '/Applications/iTerm.app' ]; then
        echo "file exists /Applications/iTerm.app"
    else
        wget https://iterm2.com/downloads/stable/iTerm2-3_0_12.zip
        tar zxvf iTerm2-3_0_12.zip
        sudo cp -Rv "iTerm.app" /Applications
        rm -rfv "iTerm.app" "iTerm2-3_0_12.zip"
    fi

    if [ -e '/Applications/SourceTree.app' ]; then
        echo "file exists /Applications/SourceTree.app"
    else
        wget https://downloads.atlassian.com/software/sourcetree/SourceTree_2.4c.zip
        tar zxvf SourceTree_2.4c.zip
        sudo cp -Rv "SourceTree.app" /Applications
        rm -rfv "SourceTree.app" "SourceTree_2.4c.zip"
    fi

    if [ -e '/Applications/Visual Studio Code.app' ]; then
        echo "file exists /Applications/Visual Studio Code.app"
    else
        wget https://az764295.vo.msecnd.net/stable/7ba55c5860b152d999dda59393ca3ebeb1b5c85f/VSCode-darwin-stable.zip
        tar zxvf VSCode-darwin-stable.zip
        sudo cp -Rv "Visual Studio Code.app" /Applications
        rm -rfv "Visual Studio Code.app" "VSCode-darwin-stable.zip"
        cp -fv ./.vscode/*.json ~/Library/Application\ Support/Code/User/ 
        sh ./install_vscode_extension.sh
    fi


    if [ -e '/Applications/Slack.app' ]; then
        echo "file exists /Applications/Slack.app"
    else
        wget https://downloads.slack-edge.com/mac_releases/Slack-2.3.3-macOS.zip
        tar zxvf Slack-2.3.3-macOS.zip
        sudo cp -Rv ".app" /Applications
        rm -rfv "Slack.app" "Slack-2.3.3-macOS.zip"
    fi

    if [ -e '/Applications/Google Chrome.app' ]; then
        echo "file exists /Applications/Google Chrome.app"
    else
        wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
        hdiutil mount googlechrome.dmg
        sudo cp -Rv "/Volumes/Google Chrome/Google Chrome.app" /Applications
        hdiutil unmount "/Volumes/Google Chrome"
        rm -rfv "googlechrome.dmg"
    fi
fi
