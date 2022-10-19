#!/bin/bash
reset_color='\033[0m'
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
darkgray='\033[1;30m'
lightred='\033[1;31m'
lightgreen='\033[1;32m'
lightyellow='\033[1;33m'
lightblue='\033[1;34m'
lightpurple='\033[1;35m'
lightcyan='\033[1;36m'
lightwhite='\033[1;37m'


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


function cnt_all_pods() {
    cnt_pods_in_nodes ""
}

function cnt_running_pods() {
    cnt_pods_in_nodes "running"
}

function cnt_crash_pods() {
    cnt_pods_in_nodes "crash"
}

function cnt_error_pods() {
    cnt_pods_in_nodes "error"
}

function cnt_evicted_pods() {
    cnt_pods_in_nodes "evicted"
}

function cnt_completed_pods() {
    cnt_pods_in_nodes "completed"
}
