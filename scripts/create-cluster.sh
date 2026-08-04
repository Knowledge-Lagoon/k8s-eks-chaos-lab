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

# ----------------------------------------
# AWS Authentication
# ----------------------------------------

echo ""
echo "===== AWS Authentication ====="
echo ""

read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="${REGION}"

echo ""
echo "Validating AWS credentials..."
echo ""

aws sts get-caller-identity

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
# Check If Cluster Already Exists
# ----------------------------------------

echo ""
echo "Checking if EKS cluster already exists..."
echo ""

if eksctl get cluster --region "${REGION}" | grep -q "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' already exists in region '${REGION}'."
  echo "Skipping cluster creation."
else
  echo "Creating EKS cluster '${CLUSTER_NAME}' in region '${REGION}'..."

  eksctl create cluster \
    --name "${CLUSTER_NAME}" \
    --region "${REGION}" \
    --nodes "${NODE_COUNT}" \
    --node-type "${NODE_TYPE}" \
    --spot
fi

# ----------------------------------------
# Configure kubectl
# ----------------------------------------

echo ""
echo "Configuring kubectl..."
echo ""

aws eks update-kubeconfig \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}"

# ----------------------------------------
# Verify Cluster
# ----------------------------------------

echo ""
echo "Verifying cluster nodes..."
echo ""

kubectl get nodes

echo ""
echo "EKS cluster '${CLUSTER_NAME}' is ready."
echo ""