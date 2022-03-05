#!/usr/bin/env bash

NAMESPACE="$1"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

KUBECTL="${BIN_DIR}/kubectl"


if ${KUBECTL} get -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group"; then
  echo "Deleting operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
  ${KUBECTL} delete -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group"
else
  echo "Unable to find operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
fi
