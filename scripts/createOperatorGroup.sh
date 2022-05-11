#!/usr/bin/env bash

NAMESPACE="$1"

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

cat <<EOT >> "${YAML_FILE}"
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${NAMESPACE}-operator-group
  namespace: ${NAMESPACE}
spec:
  targetNamespaces:
    - ${NAMESPACE}
EOT

kubectl apply -n "${NAMESPACE}" -f "${YAML_FILE}"
