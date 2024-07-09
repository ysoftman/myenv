#!/bin/bash
source ${HOME}/workspace/myenv/colors.sh

ret_value=""
check_command_existence() {
    if [[ $# != 1 ]]; then
        ret_value="fail"
        echo "usage) ${0} {command}"
        echo "ex) ${0} kubectl"
        echo "ex) ${0} stern"
        return
    fi
    local command_name=$1
    eval "type ${command_name} > /dev/null 2>&1"
    ret=$(echo $?)
    if [[ $ret != 0 && $ret != 1 && $ret != 2 ]]; then
        echo -e "${red}can't find ${command_name} command${reset_color}"
        ret_value="fail"
        return
    fi
    ret_value="ok"
}

function k8s_cnt_pods_in_nodes {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    if [[ $# != 1 ]]; then
        echo "usage) ${0} {pod_status}"
        echo "ex) ${0} running"
        echo "ex) ${0} crash"
        return
    fi

    local pod_status=$1
    for node in $(kubectl get nodes | sed 1d | awk '{print $1}'); do
        # Evicted|Complete|Error 상태는 제외
        # podsCnt=$(kubectl get pods -A -o wide --field-selector spec.nodeName=${node} | sed 1d | rg -iN -v "Evicted|Complete|Error" | wc | awk '{print $1}')
        podsCnt=$(kubectl get pods -A -o wide --field-selector spec.nodeName=${node} | sed 1d | rg -iN "${pod_status}" | wc | awk '{print $1}')
        echo -e "${green}$node -> ${podsCnt} pods${reset_color}"
    done
}


function k8s_cnt_all_pods_in_nodes {
    k8s_cnt_pods_in_nodes ""
}

function k8s_cnt_running_pods_in_nodes {
    k8s_cnt_pods_in_nodes "running"
}

function k8s_cnt_crash_pods_in_nodes {
    k8s_cnt_pods_in_nodes "crash"
}

function k8s_cnt_error_pods_in_nodes {
    k8s_cnt_pods_in_nodes "error"
}

function k8s_cnt_evicted_pods_in_nodes {
    k8s_cnt_pods_in_nodes "evicted"
}

function k8s_cnt_completed_pods_in_nodes {
    k8s_cnt_pods_in_nodes "completed"
}

function k8s_delete_evicted_pod_in_namespace {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    if [[ $# != 1 ]]; then
        echo "usage) ${0} {namespace}"
        echo "ex) ${0} aaa"
        echo "ex) ${0} bbb"
        return
    fi
    local namespace=$1
    # 참고로 정상적인 running 상태의 pod 는 .status.reason 필드가 없음
    # kubectl get pod -o=json -n ${namespace} | jq '[.items[] | select(.status.reason=="Evicted")] | sort_by(.status.startTime)' | jq '{"pod_name":.[].metadata.name, "status":.[].status.reason}'
    for pod_name in $(kubectl get pod -o=json -n ${namespace} | jq '[.items[] | select(.status.reason=="Evicted")] | sort_by(.status.startTime)' | jq '.[].metadata.name' | tr -d '"'); do
        kubectl delete pod $pod_name -n ${namespace}
    done
}

function k8s_delete_evicted_pod_in_all_namespace {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi

    for ns in $(kubectl get ns | sed 1d | awk '{print $1}'); do
        echo "check namespace: $ns"
        k8s_delete_evicted_pod_in_namespace $ns
    done
}

function k8s_stern_log {
    check_command_existence stern
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    check_command_existence jq
    if [[ $ret_value == "fail" ]]; then
        return
    fi

    if [[ $# != 1 ]]; then
        echo "usage) ${0} {pod_name_contains}"
        echo "ex) ${0} aaa"
        echo "ex) ${0} bbb"
        return
    fi
    local pod_name=$1
    # -o json 하면 message:{} 안에서 \처리 되어 사용하지 않음
    stern ".*${pod_name}.*" -A --tail 10
}

function k8s_stern_error {
    check_command_existence stern
    if [[ $ret_value == "fail" ]]; then
        return
    fi

    if [[ $# != 1 ]]; then
        echo "usage) ${0} {pod_name_contains}"
        echo "ex) ${0} aaa"
        echo "ex) ${0} bbb"
        return
    fi
    local pod_name=$1
    # message 에 status\":20 이 없는 경우
    #local jq_option='. | select (.message | contains("status\":20") | not)'
    local jq_option='. | select (.message | contains("error"))'
    stern ".*${pod_name}.*" -A --tail 10 -o json | jq ${jq_option}
}

function k8s_get_nodes_ip {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    check_command_existence jq
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    local internal_ip=""
    local external_ip=""
    for node in $(kubectl get nodes | sed 1d | awk '{print $1}'); do
        internal_ip=$(kubectl get node ${node} -o json | jq '.status.addresses[] | select(.type=="InternalIP") | .address' | tr -d '\"')
        external_ip=$(kubectl get node ${node} -o json | jq '.status.addresses[] | select(.type=="ExternalIP") | .address' | tr -d '\"')
        echo "${node}: InternalIP(${internal_ip})  ExternalIP(${external_ip})"
    done
}

function k8s_get_current_context_server {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    check_command_existence yq
    if [[ $ret_value == "fail" ]]; then
        return
    fi

    # KUBECONFIG= 환경변수 설정 기준
    # same as 'kubectx -c'
    local current_context=$(kubectl config view --flatten | yq '.current-context')
    local current_cluster=$(kubectl config view --flatten | yq ".contexts.[] | select(.name==\"${current_context}\").context.cluster")
    current_cluster_server=$(kubectl config view --flatten | yq ".clusters.[] | select(.name==\"${current_cluster}\").cluster.server")
    echo -e ${green}${current_cluster_server}${reset_color}
}

k8s_get_nodeport() {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    kubectl get svc --all-namespaces --sort-by=".spec.ports[0].nodePort" | rg -iN "nodeport|loadbalancer"
}

k8s_get_node_taints() {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    # kubectl get nodes -o json | jq '{"node-address":.items[].status.addresses[1].address, "taints":.items[].spec.taints}'
    for node in $(kubectl get nodes | sed 1d | awk '{print $1}'); do
        echo "${node}, $(kubectl describe node ${node} | rg -iN taints)"
    done
}

k8s_get_empty_namespace() {
    check_command_existence kubectl
    if [[ $ret_value == "fail" ]]; then
        return
    fi
    local temp=""
    for ns in $(k get ns | awk '{print  $1}' | sed 1d); do
        # zsh 에선 {} 로 감싸서 사용할 수 있지만, bash 호환을 위해 kubectl stderr 결과를 stdout 로 리다이렉트하자.
        # temp=$({kubectl get all -n ${ns} | rg -iN 'no resources'} 2>&1)
        temp=$(kubectl get all -n ${ns} 2>&1 | rg -iN 'no resources' --color=never)
        if [[ -n ${temp} ]]; then
            echo ${temp} "--->" ${yellow}$(k get ns ${ns} | sed 1d | awk '{print "AGE:"$3}')${reset_color}
        fi
    done
    unset temp
}
