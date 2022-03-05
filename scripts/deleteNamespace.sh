#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

NAMESPACE="$1"
KUBECTL="${BIN_DIR}/kubectl"

if [[ -z "${NAMESPACE}" ]]; then
    echo "Namespace is required as the first parameter"
    exit 1
fi

${KUBECTL} delete namespace "${NAMESPACE}" --timeout=5m --ignore-not-found=true

if ${KUBECTL} get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Delete namespace failed for ${NAMESPACE}. Deleting pods..."
  ${KUBECTL} delete pods -n "${NAMESPACE}" --all --force --grace-period=0
  ${KUBECTL} delete namespace "${NAMESPACE}" --timeout=90s
fi

if ${KUBECTL} get namespaces "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Delete namespace failed for ${NAMESPACE}. Killing the namespace..."
  BIN_DIR="${BIN_DIR}" "${SCRIPT_DIR}/kill-kube-ns" "${NAMESPACE}"
  ${KUBECTL} delete namespace "${NAMESPACE}" --wait --timeout=90s
fi

if ${KUBECTL} get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Timed out waiting for namespace to be deleted: ${NAMESPACE}"
  exit 1
else
  echo "Namespace deleted successfully: ${NAMESPACE}"
  exit 0
fi
