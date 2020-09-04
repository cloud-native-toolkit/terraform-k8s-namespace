#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

CLUSTER_NAMESPACE="$1"
if [[ -z "${CLUSTER_NAMESPACE}" ]]; then
   echo "CLUSTER_NAMESPACE should be provided as first argument"
   exit 1
fi

if [[ -n "${KUBECONFIG_IKS}" ]]; then
    export KUBECONFIG="${KUBECONFIG_IKS}"
fi

if [[ $(kubectl get secrets -n "${CLUSTER_NAMESPACE}" -o jsonpath='{ range .items[*] }{ .metadata.name }{ "\n" }{ end }' | grep icr | wc -l | xargs) -eq 0 ]]; then
    echo "*** Copying pull secrets from default namespace to ${CLUSTER_NAMESPACE} namespace"

    kubectl get secrets -n default | grep icr | sed "s/\([A-Za-z-]*\) *.*/\1/g" | while read default_secret; do
        NAME=$(echo "${default_secret}" | sed "s/default-//g")
        "${SCRIPT_DIR}/kubectl-export.sh" secret "${default_secret}" default | jq --arg NAME "${NAME}" '.metadata.name = $NAME' | kubectl -n "${CLUSTER_NAMESPACE}" create -f -
    done
else
    echo "*** Pull secrets already exist on ${CLUSTER_NAMESPACE} namespace"
fi


EXISTING_SECRETS=$(kubectl get serviceaccount/default -n "${CLUSTER_NAMESPACE}" -o json  | tr '\n' ' ' | sed -E "s/.*imagePullSecrets.: \[([^]]*)\].*/\1/g" | grep icr | wc -l | xargs)
if [[ ${EXISTING_SECRETS} -eq 0 ]]; then
    echo "*** Adding secrets to serviceaccount/default in ${CLUSTER_NAMESPACE} namespace"

    PULL_SECRETS=$(kubectl get secrets -n "${CLUSTER_NAMESPACE}" -o jsonpath='{ range .items[*] }{ "{\"name\": \""}{ .metadata.name }{ "\"}\n" }{ end }' | grep icr | grep -v "${CLUSTER_NAMESPACE}" | paste -sd "," -)
    kubectl patch -n "${CLUSTER_NAMESPACE}" serviceaccount/default -p "{\"imagePullSecrets\": [${PULL_SECRETS}]}"
else
    echo "*** Pull secrets already applied to serviceaccount/default in ${CLUSTER_NAMESPACE} namespace"
fi
