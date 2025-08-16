#!/bin/bash

# helm repo list | sed '1d'  | awk '{print "helm repo add "$1,$2}' | pbcopy
helm repo add dcgm-exporter https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add k8tz https://k8tz.github.io/k8tz/
helm repo add vector https://helm.vector.dev
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add cdf https://cdfoundation.github.io/tekton-helm-chart
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm repo add harbor https://helm.goharbor.io
helm repo add jetstack https://charts.jetstack.io
helm repo update

# search helm chart version
# helm search repo argo

# download helm chart
# helm fetch dcgm-exporter/dcgm-exporter
# helm fetch prometheus/kube-prometheus-stack
# helm fetch hashicorp/consul
# helm fetch k8tz/k8tz
# helm fetch vector/vector
# helm fetch argo/argo-cd
# helm fetch bitnami/etcd
# helm fetch cdf/tekton-pipeline
# helm fetch chartmuseum/chartmuseum
# helm fetch harbor/harbor
# helm fetch jetstack/cert-manager
