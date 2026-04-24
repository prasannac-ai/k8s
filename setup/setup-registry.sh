#!/usr/bin/env bash
set -euo pipefail

# 1. Create registry container unless it already exists
reg_name='kind-registry'
reg_port='5001'
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

echo "Local Docker registry setup completed."
echo "Registry is running on localhost:${reg_port}"
echo "You can tag and push images like: localhost:${reg_port}/my-image:latest"

# 2. Connect the registry to the cluster network if the cluster exists
if kind get clusters 2>/dev/null | grep -q "^vvce-lab-cluster$"; then
  docker network connect "kind" "${reg_name}" 2>/dev/null || true
  echo "Connected registry to kind network."
fi
