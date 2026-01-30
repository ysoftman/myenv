#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

if [[ $os_name == *"darwin"* ]]; then
    brew install colima
    # 서비스 등록, 다음부터 맥시작시 자동으로 colima 실행
    # ~/.config/default/colima.yaml 설정을 참조하게된다.(installconfig.sh 에서 설정)
    # brew services 로 등록하면 XDG_CONFIG_HOME 같은 환경변수를 설정할 수 없어 직접 설정한다.
    # brew services start colima
    echo "create launch colima plist(Property List) file"
    cat <<ZZZ >"$HOME/Library/LaunchAgents/com.ysoftman.colima.plist"
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    <key>XDG_CONFIG_HOME</key>
    <string>/Users/ysoftman/.config</string>
  </dict>
  <string>com.ysoftman.colima</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/colima</string>
    <string>start</string>
    <string>-f</string>
  </array>
  <key>StandardErrorPath</key>
  <string>/tmp/colima_error.log</string>
  <key>StandardOutPath</key>
  <string>/tmp/colima.log</string>
  <key>WorkingDirectory</key>
  <string>/Users/ysoftman</string>
</dict>
</plist>
ZZZ
    # 서비스 등록, 다음부터 맥시작시 자동으로 colima 실행
    set -x
    launchctl unload /Users/ysoftman/Library/LaunchAgents/com.ysoftman.colima.plist 2>/dev/null
    launchctl load ~/Library/LaunchAgents/com.ysoftman.colima.plist
    set +x
fi
