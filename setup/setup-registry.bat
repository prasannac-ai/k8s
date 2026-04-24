@echo off
setlocal

set REG_NAME=kind-registry
set REG_PORT=5001

:: 1. Create registry container unless it already exists
docker inspect -f "{{.State.Running}}" %REG_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    docker run -d --restart=always -p "127.0.0.1:%REG_PORT%:5000" --name "%REG_NAME%" registry:2
)

echo Local Docker registry setup completed.
echo Registry is running on localhost:%REG_PORT%
echo You can tag and push images like: localhost:%REG_PORT%/my-image:latest

:: 2. Connect the registry to the cluster network if the cluster exists
kind get clusters 2>nul | findstr /x "vvce-lab-cluster" >nul 2>&1
if %errorlevel%==0 (
    docker network connect "kind" "%REG_NAME%" >nul 2>&1
    echo Connected registry to kind network.
)

endlocal
