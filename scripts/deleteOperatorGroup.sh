#!/usr/bin/env bash

NAMESPACE="$1"
UUID="$2"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! kubectl get -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group" 1> /dev/null 2> /dev/null; then
  echo "Unable to find operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
  exit 0
fi

CLUSTER_UUID=$(kubectl get -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group" -o json | jq -r '.metadata.labels["created-by"]')

if [[ "${CLUSTER_UUID}" != "${UUID}" ]]; then
  echo "UUID of module does not match created OperatorGroup. Skipping destroy"
  exit 0
fi

echo "Deleting operator group: ${NAMESPACE}/${NAMESPACE}-operator-group"
kubectl delete -n "${NAMESPACE}" operatorgroup "${NAMESPACE}-operator-group"
