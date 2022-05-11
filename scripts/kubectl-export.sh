#!/usr/bin/env bash

KIND="$1"
RESOURCE="$2"
NAMESPACE="$3"

if [[ -n "${NAMESPACE}" ]]; then
  NAMESPACE="-n ${NAMESPACE}"
fi

if [[ -z "$TMP_DIR" ]]; then
  TMP_DIR="${PWD}/.tmp"
fi

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if kubectl get "${KIND}/${RESOURCE}" ${NAMESPACE} 1> /dev/null 2> /dev/null; then
  kubectl get "${KIND}/${RESOURCE}" ${NAMESPACE} -o json | jq 'del(.metadata.uid) | del(.metadata.selfLink) | del(.metadata.resourceVersion) | del(.metadata.namespace) | del(.metadata.creationTimestamp)'
fi
