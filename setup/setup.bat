@echo off
setlocal

set CLUSTER_NAME=vvce-lab-cluster
set SCRIPT_DIR=%~dp0

:: Pre-flight checks
where docker >nul 2>&1 || (echo docker is not installed && exit /b 1)
where kind >nul 2>&1 || (echo kind is not installed && exit /b 1)
where kubectl >nul 2>&1 || (echo kubectl is not installed && exit /b 1)
where helm >nul 2>&1 || (echo helm is not installed && exit /b 1)
docker info >nul 2>&1 || (echo Docker is not running && exit /b 1)

:: Check for existing cluster
kind get clusters 2>nul | findstr /x "%CLUSTER_NAME%" >nul 2>&1
if %errorlevel%==0 (
    set /p answer="Cluster '%CLUSTER_NAME%' exists. Delete and recreate? (y/N): "
    if /i "%answer%"=="y" kind delete cluster --name %CLUSTER_NAME%
)

:: Step 1 - Create Kind cluster
kind get clusters 2>nul | findstr /x "%CLUSTER_NAME%" >nul 2>&1
if %errorlevel% neq 0 (
    kind create cluster --config "%SCRIPT_DIR%kind-cluster.yaml" --wait 60s
)
kubectl cluster-info --context kind-%CLUSTER_NAME%

:: Step 2 - Install Metrics Server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 2>nul
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server ^
  --namespace kube-system ^
  --set args="{--kubelet-insecure-tls}" ^
  --wait --timeout 120s

:: Step 3 - Install Ingress-NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>nul
helm repo update

(
echo controller:
echo   hostPort:
echo     enabled: true
echo   service:
echo     type: NodePort
echo   nodeSelector:
echo     ingress-ready: "true"
echo   tolerations:
echo     - operator: Exists
echo   watchIngressWithoutClass: true
) > "%TEMP%\ingress-nginx-values.yaml"

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx ^
  --namespace ingress-nginx --create-namespace ^
  -f "%TEMP%\ingress-nginx-values.yaml" ^
  --timeout 300s

del "%TEMP%\ingress-nginx-values.yaml" 2>nul

kubectl wait --namespace ingress-nginx ^
  --for=condition=ready pod ^
  --selector=app.kubernetes.io/component=controller ^
  --timeout=180s

:: Step 4 - Install Kubernetes Dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ 2>nul
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard ^
  --namespace kubernetes-dashboard --create-namespace ^
  --wait --timeout 180s

kubectl apply -f "%SCRIPT_DIR%addons\dashboard-admin.yaml"
kubectl apply -f "%SCRIPT_DIR%addons\registry-config.yaml"

:: Summary
kubectl get nodes -o wide
kubectl get pods -A
echo.
echo Dashboard: kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
echo Token:     kubectl -n kubernetes-dashboard create token admin-user
echo Open:      https://localhost:8443

endlocal
