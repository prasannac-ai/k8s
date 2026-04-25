# Kind Kubernetes Cluster

Local 3-node cluster (1 control-plane + 2 workers) with metrics-server, ingress-nginx, and dashboard.

## Prerequisites

You must have Docker installed and running (Docker Desktop with 4GB+ RAM is recommended).

To install the required CLI tools (`kind`, `kubectl`, `helm`), run the script for your operating system from the `setup` directory:

###  Mac
```bash
chmod +x install-tools.sh
./install-tools.sh
```

### 🐧 Ubuntu / Debian
```bash
chmod +x install-tools-ubuntu.sh
./install-tools-ubuntu.sh
```

### 🪟 Windows (PowerShell)
```powershell
.\install-tools.ps1
```
*(If you encounter a permission issue on Windows, run this command first: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`)*

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
kubectl -n kube-system port-forward svc/headlamp 58222:80
kubectl -n kube-system create token headlamp-admin
```

Open http://localhost:58222 and paste the token.

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


