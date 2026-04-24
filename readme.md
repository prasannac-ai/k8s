# Setup

## Install pyenv on Windows
Run the following in PowerShell:
```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

## Install pyenv on Ubuntu
Run the following in your terminal:
```bash
curl https://pyenv.run | bash
```

Install the target Python version:

```bash
pyenv install 3.11.9
```

To create a pyenv virtual environment, run:

```bash
pyenv virtualenv 3.11.9 devops
```

```bash
pyenv activate devops
```

To automatically activate this environment when entering the folder, run:

```bash
pyenv local devops
```

## Running the Application

To install the dependencies and start the FastAPI server, run:

```bash
cd todo
pip install -r requirements.txt
uvicorn todo:app --port 8000 --reload
```

## Kubernetes Cluster & Registry Setup

This project uses [kind](https://kind.sigs.k8s.io/) to spin up a local Kubernetes cluster. 

### 1. Start the Local Docker Registry

Start the local Docker registry running on `localhost:5001`. This allows the cluster to natively pull locally built images without pushing to Docker Hub.

**Mac/Linux:**
```bash
./setup/setup-registry.sh
```

**Windows:**
```powershell
.\setup\setup-registry.bat
```

### 2. Create the Kubernetes Cluster

Next, create the `kind` cluster and install the base components (Metrics Server, Ingress-NGINX, Kubernetes Dashboard).

**Mac/Linux:**
```bash
./setup/setup.sh
```

**Windows:**
```powershell
.\setup\setup.bat
```
