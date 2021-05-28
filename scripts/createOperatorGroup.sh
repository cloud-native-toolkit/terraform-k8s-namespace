#!/usr/bin/env bash

NAMESPACE="$1"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p "${TMP_DIR}"

if kubectl get operatorgroup -n ${NAMESPACE}; then
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

kubectl create -n "${NAMESPACE}" -f "${YAML_FILE}"
