#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

NAMESPACE="$1"
UUID="$2"

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if [[ -z "${NAMESPACE}" ]]; then
    echo "Namespace is required as the first parameter" &>2
    exit 1
fi

if kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Namespace already exists: ${NAMESPACE}"
  exit 0
fi

if [[ "${NAMESPACE}" =~ ^openshift- ]]; then
  echo "Namespaces that start with 'openshift-' are reserved. Skipping"
  exit 0
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | \
  kubectl apply -f -

kubectl create configmap ns-create \
  -n "${NAMESPACE}" \
  --from-literal="uuid=$UUID"
