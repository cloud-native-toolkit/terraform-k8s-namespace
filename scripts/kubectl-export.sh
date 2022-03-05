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

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

KUBECTL="${BIN_DIR}/kubectl"
JQ="${BIN_DIR}/jq"

if ${KUBECTL} get "${KIND}/${RESOURCE}" ${NAMESPACE} 1> /dev/null 2> /dev/null; then
  ${KUBECTL} get "${KIND}/${RESOURCE}" ${NAMESPACE} -o json | ${JQ} 'del(.metadata.uid) | del(.metadata.selfLink) | del(.metadata.resourceVersion) | del(.metadata.namespace) | del(.metadata.creationTimestamp)'
fi
