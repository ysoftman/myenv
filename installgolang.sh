#!/bin/bash
if [[ $# != 1 ]]; then
    echo "ex) bash ${0} go1.19.2.darwin-amd64"
    echo "ex) bash ${0} go1.19.2.linux-amd64"
    exit 0
fi
golang_version=${1}
wget https://go.dev/dl/${golang_version}.tar.gz
sudo rm -rf /usr/local/go
sudo tar zxvf ${golang_version}.tar.gz -C /usr/local
rm -rfv ${golang_version}.tar.gz
