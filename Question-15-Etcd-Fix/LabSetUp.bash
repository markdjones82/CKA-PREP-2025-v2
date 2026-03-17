#!/bin/bash
set -e

# Step 1: Backup current kube-apiserver manifest
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/kube-apiserver.yaml.bak

# Step 2: Simulate migration issue — change etcd client port to peer port 2380
sudo sed -i 's/:2379/:2380/g' /etc/kubernetes/manifests/kube-apiserver.yaml

# Step 3: Show kube-apiserver pod status/logs
echo "Checking kube-apiserver container..."
KAPISERVER_ID=$(sudo crictl ps -a | grep kube-apiserver | awk '{print $1}' | head -n 1)
if [ -n "$KAPISERVER_ID" ]; then
    sudo crictl logs "$KAPISERVER_ID" | tail -n 10 || true
else
    echo "kube-apiserver pod not found yet"
fi

# Step 4: Verify that kubectl fails as API server is down
kubectl get nodes || echo "As expected, API server is down due to misconfigured etcd client port."
