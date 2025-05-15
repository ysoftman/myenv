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

# 이제는 brew 로 앱들 설치할 수 있다.
brew install iterm2 visual-studio-code rectangle brave-browser firefox google-chrome

# if [ -e '/Applications/Google Chrome.app' ]; then
#     echo "file exists /Applications/Google Chrome.app"
# else
#     wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
#     hdiutil mount googlechrome.dmg
#     sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications
#     hdiutil unmount "/Volumes/Google Chrome"
#     rm -rf "googlechrome.dmg"
# fi

# 이제는 mac 자체에서 같은 기능을 제공하고 있어 별도 설치 하지 않는다
# if [ -e '/Applications/Flux.app' ]; then
#     echo "file exists /Applications/Flux.app"
# else
#     wget https://justgetflux.com/mac/Flux.zip
#     tar zxf Flux.zip
#     sudo cp -R "./Flux.app" /Applications
#     rm -rf Flux*
# fi
