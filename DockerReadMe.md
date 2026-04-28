# Docker Quick Start Guide

This document contains basic Docker workflows for building the FastAPI `todo` application and pushing it to the local registry.

## 1. Build the Docker Image

To build the Docker image for the Todo API, run the following command from the root directory. We tag it with `localhost:5001/` so it matches our local registry namespace:

```bash
docker build -t localhost:5001/todo-api:latest ./todo
```

## 2. Run the Container

If you want to run the container locally via Docker (outside of Kubernetes) to test it, use:

```bash
docker run -d --name my-todo-app -p 8000:8000 localhost:5001/todo-api:latest
```
*The app will be accessible at [http://localhost:8000](http://localhost:8000).*

## 3. Stop the Container

To pause or stop the background container:

```bash
docker stop my-todo-app
```

## 4. Start the Container

To resume a stopped container without recreating it:

```bash
docker start my-todo-app
```

## 5. Push to Local Registry

Once your local registry is running (started via `./setup/setup-registry.sh`), you can push your built image directly to it:

```bash
docker push localhost:5001/todo-api:latest
```

## 6. List Images in Registry

To verify which images and tags are successfully stored in your local registry, you can query the registry API using `curl`:

### List all repositories:
```bash
curl http://localhost:5001/v2/_catalog
```

### List tags for the Todo API:
```bash
curl http://localhost:5001/v2/todo-api/tags/list
```

## 7. Docker Compose

### Start services:
```bash
docker compose up
```

### Start with load balancing (scaled to 2 instances):
```bash
docker compose -f docker-compose-lb.yml up --scale todo-api=2
```
