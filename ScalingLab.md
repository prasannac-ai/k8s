# Lab: Scaling & Performance

In this lab, you will learn how to scale your application manually, set resource limits, and configure automatic scaling (HPA).

## 1. Manual Scaling
Kubernetes allows you to change the number of instances (replicas) instantly.

1.  Deploy the scaling version of the app:
    ```bash
    kubectl apply -f k8s-manifests/todo-scaling.yaml
    ```
2.  Scale it up to 5 replicas manually:
    ```bash
    kubectl scale deployment/todo-api --replicas=5
    ```
3.  Verify the pods:
    ```bash
    kubectl get pods
    ```
4.  Scale it back down to 1:
    ```bash
    kubectl scale deployment/todo-api --replicas=1
    ```

## 2. Resource Monitoring
Check how much CPU and Memory your pods are actually using:

```bash
kubectl top pods
```
*(Note: It may take 1-2 minutes for the Metrics Server to gather initial data).*

## 3. Automated Scaling (HPA)
The `todo-scaling.yaml` file includes a **Horizontal Pod Autoscaler**. It is configured to keep CPU usage at **10%**. If we go over that, it will add more pods (up to 5).

### Step A: Watch the Autoscaler
Open a **new terminal** and run:
```bash
kubectl get hpa todo-hpa --watch
```

### Step B: The Stress Test
In your **main terminal**, run this loop to flood the app with requests. This will force the CPU usage to rise:

```bash
# MacOS/Linux Stress Loop
while true; do curl -s http://localhost/todos > /dev/null; done
```

```powershell
# Windows (PowerShell) Stress Loop
while($true) { Invoke-WebRequest -Uri "http://localhost/todos" -UseBasicParsing | Out-Null }
```

### Step C: Observe the Growth
Watch your **Watch Terminal**. After a minute, you should see the `REPLICAS` number jump from `1` to `2... 3... 5`.

### Step D: Scale Down
Stop the `while` loop (`Ctrl+C`). Wait a few minutes, and you will see the HPA automatically remove the extra pods to save resources.
