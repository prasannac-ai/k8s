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

# Step 4 — Install Kubernetes Dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ 2>/dev/null || true
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard --create-namespace \
  --wait --timeout 180s

kubectl apply -f "${SCRIPT_DIR}/addons/dashboard-admin.yaml"
kubectl apply -f "${SCRIPT_DIR}/addons/registry-config.yaml"

# Summary
kubectl get nodes -o wide
kubectl get pods -A
echo ""
echo "Dashboard: kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443"
echo "Token:     kubectl -n kubernetes-dashboard create token admin-user"
echo "Open:      https://localhost:8443"


# sudo usermod -aG docker $USER
# # Then log out and log back in