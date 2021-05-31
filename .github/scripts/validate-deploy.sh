#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

source ./kubeconfig

NAMESPACE=$(cat terraform.tfvars | grep namespace | sed -E "s/namespace *= *\"(.*)\"/\1/g")

echo "Checking for namespace: ${NAMESPACE}"

if ! kubectl get namespace "${NAMESPACE}"; then
  echo "Namespace not found: ${NAMESPACE}"
  exit 1
fi

if ! kubectl get operatorgroup "${NAMESPACE}-operator-group" -n "${NAMESPACE}"; then
  echo "Operator group not found: ${NAMESPACE}-operator-group"
  exit 1
fi
