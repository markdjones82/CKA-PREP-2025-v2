#!/bin/bash
set -e

echo "Setting up Extra Credit 1: Broken API Server..."

# Backup the current kube-apiserver manifest
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/kube-apiserver.yaml.bak

# Break the API server by setting an invalid service-cluster-ip-range
sudo sed -i 's|--service-cluster-ip-range=.*|--service-cluster-ip-range=999.999.0.0/16|' /etc/kubernetes/manifests/kube-apiserver.yaml

echo "Waiting for API server to detect the change..."
sleep 10

echo "[OK] Lab setup complete!"
echo "   - The kube-apiserver manifest has been modified with an invalid service CIDR"
echo "   - kubectl commands will fail until the issue is fixed"
echo "   - Use crictl to inspect logs: sudo crictl ps -a && sudo crictl logs <container-id>"
