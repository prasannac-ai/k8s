#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="vvce-lab-cluster"

# Pre-flight checks
for cmd in docker kind kubectl helm; do
  command -v "$cmd" &>/dev/null || { echo "$cmd is not installed"; exit 1; }
done
docker info &>/dev/null || { echo "Docker is not running"; exit 1; }

# Delete existing cluster if present
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  read -rp "Cluster '${CLUSTER_NAME}' exists. Delete and recreate? (y/N): " answer
  [[ "${answer}" =~ ^[Yy]$ ]] && kind delete cluster --name "${CLUSTER_NAME}"
fi

# Step 1 — Create Kind cluster
if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --config "${SCRIPT_DIR}/kind-cluster.yaml" --wait 60s
fi
kubectl cluster-info --context "kind-${CLUSTER_NAME}"

# Step 2 — Install Metrics Server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 2>/dev/null || true
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args="{--kubelet-insecure-tls}" \
  --wait --timeout 120s

# Step 3 — Install Ingress-NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
helm repo update

cat > /tmp/ingress-nginx-values.yaml <<'EOF'
controller:
  hostPort:
    enabled: true
  service:
    type: NodePort
  nodeSelector:
    ingress-ready: "true"
  tolerations:
    - operator: Exists
  watchIngressWithoutClass: true
EOF

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  -f /tmp/ingress-nginx-values.yaml \
  --timeout 300s
rm -f /tmp/ingress-nginx-values.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# Step 4 — Install Headlamp
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/ 2>/dev/null || true
helm repo update
helm upgrade --install headlamp headlamp/headlamp \
  --namespace kube-system \
  --wait --timeout 180s

kubectl apply -f "${SCRIPT_DIR}/addons/headlamp-admin.yaml"
kubectl apply -f "${SCRIPT_DIR}/addons/registry-config.yaml"

# Summary
kubectl get nodes -o wide
kubectl get pods -A
echo ""
echo "Dashboard: kubectl -n kube-system port-forward svc/headlamp 58222:80"
echo "Token:     kubectl -n kube-system create token headlamp-admin"
echo "Open:      http://localhost:58222"

# sudo usermod -aG docker $USER
# # Then log out and log back in