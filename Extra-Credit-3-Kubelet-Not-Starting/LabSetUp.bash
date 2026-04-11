#!/bin/bash
set -e

echo "Setting up Extra Credit 3: Kubelet Not Starting..."

BAD_NODE="node01"

# Backup the kubeadm-flags.env file on the broken node
# This file is present on all kubeadm-managed nodes and is sourced by the kubelet drop-in
ssh "$BAD_NODE" "sudo cp /var/lib/kubelet/kubeadm-flags.env /root/kubeadm-flags.env.bak"

# Break the kubelet by appending a wrong container runtime endpoint into kubeadm-flags.env
# sed appends the bad flag just before the closing quote of KUBELET_KUBEADM_ARGS
# Simulate a realistic typo: 'container.sock' instead of 'containerd.sock'
ssh "$BAD_NODE" "sudo sed -i 's|\"$| --container-runtime-endpoint=unix:///run/containerd/container.sock\"|' /var/lib/kubelet/kubeadm-flags.env"

# Restart kubelet so it picks up the bad config
ssh "$BAD_NODE" "sudo systemctl daemon-reload"
ssh "$BAD_NODE" "sudo systemctl restart kubelet || true"

echo "Waiting for kubelet to fail..."
sleep 10

echo "Waiting 60 seconds for the node status to update to NotReady..."
sleep 60

echo "[OK] Lab setup complete!"
