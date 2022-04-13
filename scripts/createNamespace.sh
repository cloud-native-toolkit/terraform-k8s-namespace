#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -z "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

NAMESPACE="$1"

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if [[ -z "${NAMESPACE}" ]]; then
    echo "Namespace is required as the first parameter"
    exit 1
fi

if kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Namespace already exists: ${NAMESPACE}"
  exit 0
fi

kubectl create namespace "${NAMESPACE}"
