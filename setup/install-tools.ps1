# PowerShell script to install Kubernetes tools on Windows using Winget

Write-Host "Installing kind, kubectl, and helm..." -ForegroundColor Cyan

winget install -e --id Kubernetes.kind
winget install -e --id Kubernetes.kubectl
winget install -e --id Helm.Helm

Write-Host "`n---------------------------------------" -ForegroundColor Green
Write-Host "Verification:" -ForegroundColor Green
kind version
kubectl version --client
helm version
Write-Host "---------------------------------------" -ForegroundColor Green
Write-Host "All tools installed successfully! Please restart your terminal." -ForegroundColor Yellow
