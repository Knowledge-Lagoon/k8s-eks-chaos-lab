#!/bin/bash

set -e

# ----------------------------------------
# Load Configuration
# ----------------------------------------

CONFIG_FILE="$(dirname "$0")/../config/cluster.conf"

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
read -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="${AWS_REGION}"

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
  echo "WARNING: kubectl is not installed"
  echo "Continuing because cluster deletion only requires eksctl and aws CLI"
}

echo "Required prerequisites found."

# ----------------------------------------
# Show Target Cluster
# ----------------------------------------

echo ""
echo "Cluster deletion details:"
echo "Cluster Name : ${CLUSTER_NAME}"
echo "Region       : ${AWS_REGION}"
echo ""

# ----------------------------------------
# Check If Cluster Exists
# ----------------------------------------

echo "Checking if cluster exists..."
echo ""

if eksctl get cluster --region "${AWS_REGION}" | grep -q "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' found."
else
  echo "Cluster '${CLUSTER_NAME}' does not exist in region '${AWS_REGION}'."
  echo "Nothing to delete."
  exit 0
fi

# ----------------------------------------
# Confirm Deletion
# ----------------------------------------

echo ""
echo "WARNING: This will delete the EKS cluster and associated resources."
echo ""

read -p "Are you sure you want to delete '${CLUSTER_NAME}'? Type 'yes' to continue: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Cluster deletion cancelled."
  exit 0
fi

# ----------------------------------------
# Delete Cluster
# ----------------------------------------

echo ""
echo "Deleting EKS cluster '${CLUSTER_NAME}'..."
echo ""

eksctl delete cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}"

echo ""
echo "EKS cluster '${CLUSTER_NAME}' deletion completed."
echo ""