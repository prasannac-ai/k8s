#!/usr/bin/env bash
# Script to completely remove the laboratory environment

set -euo pipefail

CLUSTER_NAME="k8s-lab-cluster"
REG_NAME="kind-registry"

echo "Deleting Kind cluster: ${CLUSTER_NAME}..."
kind delete cluster --name "${CLUSTER_NAME}" || true

echo "Stopping and removing local registry: ${REG_NAME}..."
docker stop "${REG_NAME}" 2>/dev/null || true
docker rm "${REG_NAME}" 2>/dev/null || true

echo "---------------------------------------"
echo "Workstation is clean!"
