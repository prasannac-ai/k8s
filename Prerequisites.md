# Prerequisites & Tools

To set up this laboratory environment, you must have the following tools installed on your local machine:

## 1. Docker
Docker is required because `kind` runs Kubernetes nodes as Docker containers.
- **Windows/Mac:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- **Linux:** Install [Docker Engine](https://docs.docker.com/engine/install/).

## 2. kind (Kubernetes in Docker)
The tool used to create local Kubernetes clusters.
- **Installation:** [kind.sigs.k8s.io](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## 3. kubectl
The command-line tool for interacting with Kubernetes clusters.
- **Installation:** [kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

## 4. Helm
The package manager for Kubernetes, used to install system addons like the Dashboard and Ingress Controller.
- **Installation:** [helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

---

## 🛠️ Verification
Once installed, you should be able to run these commands in your terminal and see version numbers:

```bash
docker version
kind version
kubectl version --client
helm version
```
