#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAMESPACE="$1"

if [[ -z "${NAMESPACE}" ]]; then
    echo "Namespace is required as the first parameter"
    exit 1
fi

kubectl get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null && \
  kubectl delete namespace "${NAMESPACE}" --wait --timeout=30s

if kubectl get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Delete namespace failed for ${NAMESPACE}. Killing the namespace..."
  "${SCRIPT_DIR}/kill-kube-ns" "${NAMESPACE}"
fi

exit 0
