#!/bin/bash
set -e

echo "Setting up Extra Credit 3: Kubelet Not Starting..."

BAD_NODE="node01"

# Backup kubelet config on the broken node
ssh "$BAD_NODE" "sudo cp /var/lib/kubelet/config.yaml /root/kubelet-config.yaml.bak 2>/dev/null || true"

# Break the kubelet by pointing to a wrong container runtime socket
# Check if the kubelet drop-in exists and modify it
KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
ssh "$BAD_NODE" "if [[ -f '$KUBELET_DROPIN' ]]; then sudo cp '$KUBELET_DROPIN' /root/10-kubeadm.conf.bak; fi"

# Add a bad --container-runtime-endpoint flag
ssh "$BAD_NODE" "sudo mkdir -p /etc/default"
ssh "$BAD_NODE" "echo 'KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/bad-socket.sock' | sudo tee /etc/default/kubelet > /dev/null"

# Restart kubelet so it picks up the bad config
ssh "$BAD_NODE" "sudo systemctl daemon-reload"
ssh "$BAD_NODE" "sudo systemctl restart kubelet || true"

echo "Waiting for kubelet to fail..."
sleep 10

echo "Waiting 60 seconds for the node status to update to NotReady..."
sleep 60

echo "[OK] Lab setup complete!"
