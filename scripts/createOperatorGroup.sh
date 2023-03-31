#!/usr/bin/env bash

NAMESPACE="$1"
UUID="$2"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p "${TMP_DIR}"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ $(kubectl get operatorgroup -n "${NAMESPACE}" | wc -l) -gt 0 ]]; then
  echo "OperatorGroup already present in namespace: ${NAMESPACE}"
  exit 0
fi

YAML_FILE="${TMP_DIR}/${NAMESPACE}-operator-group.yaml"

cat <<EOT | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${NAMESPACE}-operator-group
  namespace: ${NAMESPACE}
  labels:
    created-by: ${UUID}
spec:
  targetNamespaces:
    - ${NAMESPACE}
EOT
