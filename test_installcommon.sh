#!/bin/bash
# mac 에서 colima 를 사용환경에서 테스트하기
# installcommon.sh 를 컨테이너에서 실행해 apt/yum 설치 실패 패키지를 확인한다.
# usage: ./test_installcommon.sh [image] (default: debian:stable)

# 테스트 실행
# bash ./test_installcommon.sh
# bash ./test_installcommon.sh ubuntu:stable
# bash ./test_installcommon.sh rockylinux/rockylinux:9

image=${1:-debian:stable}
cd "$(dirname "$0")" || exit 1
docker info >/dev/null 2>&1 || colima start || exit 1

# container 에서 installcommon.sh 을 설치해 에러를 파악한다.
docker run --rm --pull=always -v "$PWD":/myenv:ro -w /myenv -e DEBIAN_FRONTEND=noninteractive "$image" bash -c '
(apt-get update -qq && apt-get install -y -qq sudo && echo "Defaults env_keep += DEBIAN_FRONTEND" >/etc/sudoers.d/debian_frontend || yum install -y -q sudo) >/dev/null || { echo "FAIL (sudo install)"; exit 1; }
bash ./installcommon.sh 2>&1 | tee /tmp/install.log
grep -E "^(E|Error): |^\[error\]|^dpkg: error|subprocess returned error" /tmp/install.log |
    grep -v "Sub-process /usr/bin/dpkg" | awk "!seen[\$0]++" >/tmp/errors.log
if [ -s /tmp/errors.log ]; then
    echo "===== errors ====="
    cat /tmp/errors.log
    echo "FAIL ($0)"
    exit 1
fi
echo "OK"
' "$image"
