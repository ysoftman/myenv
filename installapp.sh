#!/bin/bash

if [[ $(uname) != 'Darwin' ]]; then
    echo 'it is not mac system.'
    exit 0
fi

# sudo rm -rf '/Applications/iTerm.app'
# sudo rm -rf '/Applications/Visual Studio Code.app'
# sudo rm -rf '/Applications/Google Chrome.app'
# sudo rm -rf '/Applications/Firefox.app'
# sudo rm -rf '/Applications/Spectacle.app'
# sudo rm -rf '/Applications/Flux.app'


if [ -e '/Applications/iTerm.app' ]; then
    echo "file exists /Applications/iTerm.app"
else
    wget https://iterm2.com/downloads/stable/iTerm2-3_2_2.zip
    tar zxf iTerm2-3_2_2.zip
    sudo cp -R "iTerm.app" /Applications
    rm -rf iTerm*
fi

if [ -e '/Applications/Visual Studio Code.app' ]; then
    echo "file exists /Applications/Visual Studio Code.app"
else
    wget https://az764295.vo.msecnd.net/stable/f46c4c469d6e6d8c46f268d1553c5dc4b475840f/VSCode-darwin-stable.zip
    # symbolic links 를 보존하기 위해 unzip 사용
    unzip VSCode-darwin-stable.zip
    sudo cp -R "Visual Studio Code.app" /Applications
    rm -rf "Visual Studio Code.app" "VSCode-darwin-stable.zip"
    # 최초 실행 후 ctrl+shift+p -> install 'code' command in PATH 실행
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
    rm -rf Firefox*
fi

if [ -e '/Applications/Flux.app' ]; then
    echo "file exists /Applications/Flux.app"
else
    wget https://justgetflux.com/mac/Flux.zip
    tar zxf Flux.zip
    sudo cp -R "./Flux.app" /Applications
    rm -rf Flux*
fi
