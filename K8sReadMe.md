


## 1. Deploy the Application


```bash
kubectl apply -f k8s-manifests/todo-app.yaml
kubectl apply -f k8s-manifests/ingress.yaml
```

## 2. Verify the Pods

check if your application's pods are running successfully:

```bash
kubectl get pods
```

## 3. Verify the Service

To ensure the networking service has been created:

```bash
kubectl get services
```

## 4. Access the Application

### Option A: Direct Access (via Ingress)
Since port 80 is mapped in `kind`, you can access it directly:
[http://localhost/todos](http://localhost/todos)

### Option B: Port Forwarding (Manual)
If Ingress is not used, forward a local port:
```bash
kubectl port-forward service/todo-api-service 8080:80
```
[http://localhost:8080/todos](http://localhost:8080/todos)

Press `Ctrl+C` in your terminal anytime to stop the port-forwarding.

## 5. Clean Up
Remove the deployment and service from the cluster:

```bash
kubectl delete -f k8s-manifests/todo-app.yaml
kubectl delete -f k8s-manifests/ingress.yaml
```
