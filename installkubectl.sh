#!/bin/bash
set -e

printf "install kubectl,kubecolor in %s\n" "$(uname)"

if [[ $(uname -o 2>/dev/null) == 'Android' ]]; then
    pkg update
    pkg upgrade
    pkg install -y kubectl
elif [[ $(uname) == 'Darwin' ]]; then
    brew install kubectl kubecolor
elif [[ $(uname) == 'Linux' ]]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    rm -f kubectl kubectl.sha256
    # Requires Go 1.22 (or later)
    # bash ./installgolang.sh go1.22.6.linux-amd64
    go install github.com/kubecolor/kubecolor@latest
fi
