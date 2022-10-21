#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

function cnt_pods_in_nodes() {
    ret=$(kubectl)
    if [[ $(echo $?) != 0 ]]; then
        echo -e "${red}can't find kubectl command${reset_color}"
        exit 1
    fi
    pod_status=$1
    for node in $(kubectl get nodes | sed 1d | awk '{print $1}'); do
        # Evicted|Complete|Error 상태는 제외
        # podsCnt=$(kubectl get pods -A -o wide --field-selector spec.nodeName=${node} | sed 1d | rg -i -v "Evicted|Complete|Error" | wc | awk '{print $1}')
        podsCnt=$(kubectl get pods -A -o wide --field-selector spec.nodeName=${node} | sed 1d | rg -i "${pod_status}" | wc | awk '{print $1}')
        echo -e "${green}$node -> ${podsCnt} pods${reset_color}"
    done
}


function cnt_all_pods_in_nodes() {
    cnt_pods_in_nodes ""
}

function cnt_running_pods_in_nodes() {
    cnt_pods_in_nodes "running"
}

function cnt_crash_pods_in_nodes() {
    cnt_pods_in_nodes "crash"
}

function cnt_error_pods_in_nodes() {
    cnt_pods_in_nodes "error"
}

function cnt_evicted_pods_in_nodes() {
    cnt_pods_in_nodes "evicted"
}

function cnt_completed_pods_in_nodes() {
    cnt_pods_in_nodes "completed"
}
