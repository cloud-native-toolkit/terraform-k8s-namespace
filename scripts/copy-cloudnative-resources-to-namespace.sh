#!/usr/bin/env bash

print_usage() {
    echo "Missing required arguments"
    echo "Usage: $0 {KIND} {TO_NAMESPACE} [{FROM_NAMESPACE}]"
}

if [[ -z "$1" ]]; then
    print_usage
    exit 1
else
   KIND="$1"
fi

if [[ -z "$2" ]]; then
    print_usage
    exit 1
else
   TO_NAMESPACE="$2"
fi

if [[ -z "$3" ]]; then
   FROM_NAMESPACE="default"
else
   FROM_NAMESPACE="$3"
fi

RESOURCE_LABEL="grouping=garage-cloud-native-toolkit"

if kubectl get "${KIND}" -l "${RESOURCE_LABEL}" -n "${FROM_NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "*** ${KIND} found in ${FROM_NAMESPACE} namespace using label ${RESOURCE_LABEL}"
  kubectl get "${KIND}" -l "${RESOURCE_LABEL}" -n "${FROM_NAMESPACE}"
else
  echo "*** ${KIND} could not be found in ${FROM_NAMESPACE} namespace using label ${RESOURCE_LABEL}"
  exit 0
fi

kubectl get "${KIND}" -l "${RESOURCE_LABEL}" -n "${FROM_NAMESPACE}" -o jsonpath='{ range .items[*] }{ .metadata.name }{ "\n" }{ end }' | \
while read -r name; do
  if kubectl get "${KIND}/${name}" -n "${TO_NAMESPACE}"; then
    echo "*** ${KIND}/${name} already exists in ${TO_NAMESPACE} namespace"
  else
    echo "*** Copying ${KIND}/${name} from ${FROM_NAMESPACE} namespace to ${TO_NAMESPACE} namespace"

    kubectl get "${KIND}/${name}" -n "${FROM_NAMESPACE}" -o yaml --export | kubectl apply -n "${TO_NAMESPACE}" -f -
  fi
done
