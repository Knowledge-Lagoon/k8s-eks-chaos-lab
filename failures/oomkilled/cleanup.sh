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
TARGET_CLUSTER="${1:-${CLUSTER_NAME}}"

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
echo "Deleting OOMKilled deployment..."
echo ""

kubectl delete -f "${SCRIPT_DIR}/deployment.yaml" --ignore-not-found=true

echo ""
echo "Deleting namespace '${NAMESPACE}'..."
echo ""

kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true

echo ""
echo "OOMKilled scenario cleaned up."
echo ""
