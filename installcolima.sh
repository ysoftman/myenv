#!/bin/bash

os_name=$(uname -o | tr '[:upper:]' '[:lower:]')

if [[ $os_name == *"darwin"* ]]; then
    brew install colima
    # 서비스 등록, 다음부터 맥시작시 자동으로 colima 실행
    # ~/.config/default/colima.yaml 설정을 참조하게된다.(installconfig.sh 에서 설정)
    brew services start colima
fi
