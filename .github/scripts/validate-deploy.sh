#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

source ./kubeconfig

NAMESPACE=$(cat terraform.tfvars | grep namespace | sed -E "s/namespace *= *\"(.*)\"/\1/g")

echo "Checking for namespace: ${NAMESPACE}"

if ! kubectl get namespace "${NAMESPACE}"; then
  echo "Namespace not found: ${NAMESPACE}" >&2
  exit 1
fi

if ! kubectl get operatorgroup -A 1> /dev/null 2> /dev/null; then
  echo "OperatorGroup resource not available in cluster"
  exit 0
fi

if ! kubectl get operatorgroup "${NAMESPACE}-operator-group" -n "${NAMESPACE}"; then
  echo "Operator group not found: ${NAMESPACE}-operator-group" >&2
  exit 1
fi
