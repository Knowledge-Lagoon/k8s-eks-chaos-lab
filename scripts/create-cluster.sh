#!/bin/bash

set -e

# ----------------------------------------
# Load Configuration
# ----------------------------------------

CONFIG_FILE="$(dirname "$0")/../config/cluster.conf"
echo "CONFIG FILE: $CONFIG_FILE"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"
echo "Loaded configuration:"
echo "Cluster: $CLUSTER_NAME"
echo "Region : $AWS_REGION"

if [ "$#" -gt 0 ]; then
  CLUSTER_TARGETS=("$@")
elif declare -p CLUSTER_NAMES >/dev/null 2>&1; then
  CLUSTER_TARGETS=("${CLUSTER_NAMES[@]}")
else
  CLUSTER_TARGETS=("$CLUSTER_NAME")
fi

echo "Clusters to create: ${CLUSTER_TARGETS[*]}"

# ----------------------------------------
# Verify Required Tools
# ----------------------------------------

echo ""
echo "Checking prerequisites..."
echo ""

command -v aws >/dev/null 2>&1 || {
  echo "ERROR: aws CLI is not installed"
  exit 1
}

command -v eksctl >/dev/null 2>&1 || {
  echo "ERROR: eksctl is not installed"
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "ERROR: kubectl is not installed"
  exit 1
}

echo "All prerequisites found."

# ----------------------------------------
# Create or Reuse Clusters
# ----------------------------------------

echo ""
echo "Checking EKS clusters..."
echo ""

for cluster_name in "${CLUSTER_TARGETS[@]}"; do
  echo ""
  echo "=== Processing cluster '${cluster_name}' ==="
  echo ""

  if eksctl get cluster --region "${AWS_REGION}" | grep -q "${cluster_name}"; then
    echo "Cluster '${cluster_name}' already exists in region '${AWS_REGION}'."
    echo "Skipping cluster creation."
  else
    echo "Creating EKS cluster '${cluster_name}' in region '${AWS_REGION}'..."

    eksctl create cluster \
      --name "${cluster_name}" \
      --region "${AWS_REGION}" \
      --nodes "${NODE_COUNT}" \
      --node-type "${NODE_TYPE}" \
      --spot
  fi

  echo ""
  echo "Configuring kubectl for '${cluster_name}'..."
  echo ""

  aws eks update-kubeconfig \
    --region "${AWS_REGION}" \
    --name "${cluster_name}"

  echo ""
  echo "Verifying cluster nodes for '${cluster_name}'..."
  echo ""

  kubectl get nodes

  echo ""
  echo "EKS cluster '${cluster_name}' is ready."
  echo ""
done