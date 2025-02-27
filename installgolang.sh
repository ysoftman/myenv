#!/bin/bash
if [[ $# != 1 ]]; then
    echo "ex) bash ${0} go1.22.6.darwin-amd64"
    echo "ex) bash ${0} go1.22.6.linux-amd64"
    exit 0
fi
golang_version=${1}
wget https://go.dev/dl/${golang_version}.tar.gz
# 시스템 전체적으로 golang 버전업이 필요할때
# sudo rm -rf /usr/local/go
# sudo tar zxvf ${golang_version}.tar.gz -C /usr/local
rm -rf $HOME/go
tar zxvf ${golang_version}.tar.gz -C $HOME
rm -rfv ${golang_version}.tar.gz
