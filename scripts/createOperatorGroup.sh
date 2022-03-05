#!/usr/bin/env bash

NAMESPACE="$1"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p "${TMP_DIR}"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

KUBECTL="${BIN_DIR}/kubectl"

if [[ $(${KUBECTL} get operatorgroup -n "${NAMESPACE}" | wc -l) -gt 0 ]]; then
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

${KUBECTL} create -n "${NAMESPACE}" -f "${YAML_FILE}"
