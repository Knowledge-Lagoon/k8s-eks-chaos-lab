#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$(cd "${SCRIPT_DIR}/../.." && pwd)/config/cluster.conf"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "ERROR: Config file not found: ${CONFIG_FILE}"
  exit 1
fi

source "${CONFIG_FILE}"

NAMESPACE="chaos-lab"
TARGET_CLUSTER="${CLUSTER_NAME}"

if ! aws eks describe-cluster --name "${TARGET_CLUSTER}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  echo "ERROR: Cluster '${TARGET_CLUSTER}' was not found in region '${AWS_REGION}'."
  exit 1
fi

echo ""
echo "Using cluster '${TARGET_CLUSTER}'..."
echo ""

aws eks update-kubeconfig \
  --region "${AWS_REGION}" \
  --name "${TARGET_CLUSTER}"

echo ""
echo "Creating namespace..."
echo ""

kubectl create namespace ${NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Deploying OOMKilled scenario..."
echo ""

kubectl apply -f "${SCRIPT_DIR}/deployment.yaml"

echo ""
echo "Waiting for pod creation..."
echo ""

sleep 15

kubectl get pods -n ${NAMESPACE}

echo ""
echo "OOMKilled scenario deployed."
echo ""

echo "Useful commands:"
echo ""
echo "kubectl get pods -n ${NAMESPACE}"
echo "kubectl describe pod -n ${NAMESPACE} <pod-name>"
echo "kubectl logs -n ${NAMESPACE} pod/<pod-name>"
