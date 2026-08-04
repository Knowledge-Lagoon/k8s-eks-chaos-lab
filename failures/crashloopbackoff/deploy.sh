#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

NAMESPACE="chaos-lab"

echo ""
echo "Creating namespace..."
echo ""

kubectl create namespace ${NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Deploying CrashLoopBackOff scenario..."
echo ""

kubectl apply -f "${SCRIPT_DIR}/deployment.yaml"

echo ""
echo "Waiting for pod creation..."
echo ""

sleep 15

kubectl get pods -n ${NAMESPACE}

echo ""
echo "CrashLoopBackOff scenario deployed."
echo ""

echo "Useful commands:"
echo ""
echo "kubectl get pods -n ${NAMESPACE}"
echo "kubectl describe pod -n ${NAMESPACE} <pod-name>"
echo "kubectl logs -n ${NAMESPACE} deployment/crashloop-demo"