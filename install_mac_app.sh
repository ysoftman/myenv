#!/bin/bash
# sudo rm -rf '/Applications/iTerm.app'
# sudo rm -rf '/Applications/SourceTree.app'
# sudo rm -rf '/Applications/Visual Studio Code.app'
# sudo rm -rf '/Applications/Slack.app'
# sudo rm -rf '/Applications/Google Chrome.app'
# sudo rm -rf '/Applications/Firefox.app'
# sudo rm -rf '/Applications/Spectacle.app'
# sudo rm -rf '/Applications/Flux.app'

if [[ $(uname) == 'Darwin' ]]; then

    if [ -e '/Applications/iTerm.app' ]; then
        echo "file exists /Applications/iTerm.app"
    else
        wget https://iterm2.com/downloads/stable/iTerm2-3_2_0.zip
        tar zxf iTerm2-3_2_0.zip
        sudo cp -R "iTerm.app" /Applications
        rm -rf "iTerm*"
    fi

    if [ -e '/Applications/SourceTree.app' ]; then
        echo "file exists /Applications/SourceTree.app"
    else
        wget https://downloads.atlassian.com/software/sourcetree/Sourcetree_2.7.6a.zip
        tar zxf Sourcetree_2.7.6a.zip
        sudo cp -R "SourceTree.app" /Applications
        rm -rf "SourceTree*"
    fi

    if [ -e '/Applications/Visual Studio Code.app' ]; then
        echo "file exists /Applications/Visual Studio Code.app"
    else
        wget https://az764295.vo.msecnd.net/stable/7ba55c5860b152d999dda59393ca3ebeb1b5c85f/VSCode-darwin-stable.zip
        tar zxf VSCode-darwin-stable.zip
        sudo cp -R "Visual Studio Code.app" /Applications
        rm -rf "Visual Studio Code.app" "VSCode-darwin-stable.zip"
    fi

    if [ -e '/Applications/Slack.app' ]; then
        echo "file exists /Applications/Slack.app"
    else
        wget https://downloads.slack-edge.com/mac_releases/Slack-2.3.3-macOS.zip
        tar zxf Slack-2.3.3-macOS.zip
        sudo cp -R "Slack.app" /Applications
        rm -rf "Slack*"
    fi

    if [ -e '/Applications/Google Chrome.app' ]; then
        echo "file exists /Applications/Google Chrome.app"
    else
        wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
        hdiutil mount googlechrome.dmg
        sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications
        hdiutil unmount "/Volumes/Google Chrome"
        rm -rf "googlechrome.dmg"
    fi

    if [ -e '/Applications/Firefox.app' ]; then
        echo "file exists /Applications/Firefox.app"
    else
        wget https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0/mac/ko/Firefox%2062.0.dmg
        hdiutil mount 'Firefox 62.0.dmg'
        sudo cp -R "/Volumes/Firefox/Firefox.app" /Applications
        hdiutil unmount "/Volumes/Firefox"
        rm -rf "Firefox*"
    fi

    if [ -e '/Applications/Spectacle.app' ]; then
        echo "file exists /Applications/Spectacle.app"
    else
        wget https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip
        tar zxf Spectacle+1.2.zip
        sudo cp -R "./Spectacle.app" /Applications
        rm -rf "Spectacle*"
    fi

    if [ -e '/Applications/Flux.app' ]; then
        echo "file exists /Applications/Flux.app"
    else
        wget https://justgetflux.com/mac/Flux.zip
        tar zxf Flux.zip
        sudo cp -R "./Flux.app" /Applications
        rm -rf "Flux*"
    fi
fi
