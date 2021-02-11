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
mkdir -p "${TMP_DIR}/bin" &> /dev/null

if ! command -v jq &> /dev/null; then
  curl -sLo "${TMP_DIR}/bin/jq" https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  export PATH="$PATH:${TMP_DIR}/bin"
fi

if kubectl get "${KIND}/${RESOURCE}" ${NAMESPACE} 1> /dev/null 2> /dev/null; then
  kubectl get "${KIND}/${RESOURCE}" ${NAMESPACE} -o json | jq 'del(.metadata.uid) | del(.metadata.selfLink) | del(.metadata.resourceVersion) | del(.metadata.namespace) | del(.metadata.creationTimestamp)'
fi
