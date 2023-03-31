#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

NAMESPACE="$1"
UUID="$2"

if [[ -z "${NAMESPACE}" ]]; then
    echo "Namespace is required as the first parameter"
    exit 1
fi

if ! kubectl get configmap ns-create -n "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Namespace create configmap not found. Skipping destroy"
  exit 0
fi

## Check that this module created the namespace before destroying it

OLM_CONFIG=$(kubectl get configmap olm-install -n default -o json | jq -c '.data')

CLUSTER_UUID=$(echo "${OLM_CONFIG}" | jq -r '.uuid // "empty"')

if [[ "${CLUSTER_UUID}" != "${UUID}" ]]; then
  echo "UUID of module does not match created namespace. Skipping destroy"
  exit 0
fi

kubectl delete namespace "${NAMESPACE}" --timeout=5m --ignore-not-found=true

if kubectl get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Delete namespace failed for ${NAMESPACE}. Deleting pods..."
  kubectl delete pods -n "${NAMESPACE}" --all --force --grace-period=0
  kubectl delete namespace "${NAMESPACE}" --timeout=90s
fi

if kubectl get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Delete namespace failed for ${NAMESPACE}. Killing the namespace..."
  BIN_DIR="${BIN_DIR}" "${SCRIPT_DIR}/kill-kube-ns" "${NAMESPACE}"
  kubectl delete namespace "${NAMESPACE}" --wait --timeout=90s
fi

if kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Timed out waiting for namespace to be deleted: ${NAMESPACE}"
  exit 1
else
  echo "Namespace deleted successfully: ${NAMESPACE}"
  exit 0
fi
