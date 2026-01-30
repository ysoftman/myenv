#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

if [[ $os_name == *"darwin"* ]]; then
    brew install colima

    echo "create launch colima plist(Property List) file"
    cat <<ZZZ >"$HOME/Library/LaunchAgents/com.ysoftman.colima.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ysoftman.colima</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/colima</string>
        <string>start</string>
        <string>--kubernetes</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/colima.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/colima.err</string>
</dict>
</plist>
ZZZ

    # 서비스 등록, 다음부터 맥시작시 자동으로 colima 실행
    set -x
    launchctl unload /Users/ysoftman/Library/LaunchAgents/com.ysoftman.colima.plist 2>/dev/null
    launchctl load ~/Library/LaunchAgents/com.ysoftman.colima.plist
    set +x
fi
