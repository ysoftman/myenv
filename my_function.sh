#!/bin/bash
function cnt_pods_in_nodes() {
    ret=$(kubectl)
    if [[ $(echo $?) != 0 ]]; then
        echo "can't find kubectl command"
        exit 1
    fi

    for node in $(kubectl get nodes | sed 1d | awk '{print $1}'); do
        podsCnt=$(kubectl get pods -A -o wide --field-selector spec.nodeName=${node} | sed 1d | wc | awk '{print $1}')
        echo "  $node -> ${podsCnt} pods"
    done
}
