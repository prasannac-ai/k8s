@echo off
setlocal

set CLUSTER_NAME=vvce-lab-cluster
set REG_NAME=kind-registry

echo Deleting Kind cluster: %CLUSTER_NAME%...
kind delete cluster --name %CLUSTER_NAME%

echo Stopping and removing local registry: %REG_NAME%...
docker stop %REG_NAME% >nul 2>&1
docker rm %REG_NAME% >nul 2>&1

echo ---------------------------------------
echo Workstation is clean!

endlocal
