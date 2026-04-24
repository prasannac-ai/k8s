# Kind Kubernetes Cluster

Local 3-node cluster (1 control-plane + 2 workers) with metrics-server, ingress-nginx, and dashboard.

## Prerequisites

- Docker Desktop (running, 4GB+ RAM)
- kind
- kubectl
- helm

## Setup

```bash
chmod +x setup.sh teardown.sh
./setup.sh
```

## Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl top nodes
```

## Access Dashboard

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
kubectl -n kubernetes-dashboard create token admin-user
```

Open https://localhost:8443 and paste the token.

## Test Ingress

```bash
kubectl create deployment hello --image=nginx --port=80
kubectl expose deployment hello --port=80
kubectl create ingress hello --class=nginx --rule="hello.local/=hello:80"
echo "127.0.0.1 hello.local" | sudo tee -a /etc/hosts
curl http://hello.local
```

## Teardown

```bash
./teardown.sh
```


