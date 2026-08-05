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
echo "Deleting CrashLoopBackOff deployment..."
echo ""

kubectl delete deployment crashloop-demo -n "${NAMESPACE}" --ignore-not-found=true

echo ""
echo "Deleting namespace '${NAMESPACE}'..."
echo ""

kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true

echo ""
echo "CrashLoopBackOff scenario cleaned up."
echo ""
