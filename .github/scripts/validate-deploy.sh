#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

export KUBECONFIG="~/.kube/config"

NAMESPACE=$(cat terraform.tfvars | grep namespace | sed -E "s/namespace *= *\"(.*)\"/\1/g")

echo "Checking for namespace: ${NAMESPACE}"

#kubectl get namespace "${NAMESPACE}"
