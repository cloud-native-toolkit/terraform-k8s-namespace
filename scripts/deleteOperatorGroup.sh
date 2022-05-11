#!/usr/bin/env bash

NAMESPACE="$1"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if kubectl get -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group"; then
  echo "Deleting operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
  kubectl delete -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group"
else
  echo "Unable to find operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
fi
