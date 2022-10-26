#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

ret_value=""
check_kubectl() {
    ret=$(kubectl)
    if [[ $(echo $?) != 0 ]]; then
        echo -e "${red}can't find kubectl command${reset_color}"
        ret_value="fail"
        return
    fi
    ret_value="ok"
}

function cnt_pods_in_nodes() {
    check_kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    if [[ $# != 1 ]]; then
        echo "usage) ${0} {pod_status}"
        echo "ex) ${0} running"
        echo "ex) ${0} crash"
        return
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


function delete_evicted_pod_in_namespace() {
    check_kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    if [[ $# != 1 ]]; then
        echo "usage) ${0} {namespace}"
        echo "ex) ${0} aaa"
        echo "ex) ${0} bbb"
        return
    fi
    namespace=$1
    # 참고로 정상적인 running 상태의 pod 는 .status.reason 필드가 없음
    # kubectl get pod -o=json -n ${namespace} | jq '[.items[] | select(.status.reason=="Evicted")] | sort_by(.status.startTime)' | jq '{"pod_name":.[].metadata.name, "status":.[].status.reason}'
    for pod_name in $(kubectl get pod -o=json -n ${namespace} | jq '[.items[] | select(.status.reason=="Evicted")] | sort_by(.status.startTime)' | jq '.[].metadata.name' | tr -d '"'); do
        kubectl delete pod $pod_name -n ${namespace}
    done
}


function delete_evicted_pod_in_all_namespace() {
    check_kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi

    for ns in $(kubectl get ns | sed 1d | awk '{print $1}'); do
        echo "check namespace: $ns"
        delete_evicted_pod_in_namespace $ns
    done
}
