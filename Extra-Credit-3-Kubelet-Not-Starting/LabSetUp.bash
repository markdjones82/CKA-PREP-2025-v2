#!/bin/bash
set -e

echo "Setting up Extra Credit 3: Kubelet Not Starting..."

# Backup kubelet config
sudo cp /var/lib/kubelet/config.yaml /root/kubelet-config.yaml.bak 2>/dev/null || true

# Break the kubelet by pointing to a wrong container runtime socket
# Check if the kubelet drop-in exists and modify it
KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
if [[ -f "$KUBELET_DROPIN" ]]; then
  sudo cp "$KUBELET_DROPIN" /root/10-kubeadm.conf.bak
fi

# Add a bad --container-runtime-endpoint flag
sudo mkdir -p /etc/default
echo 'KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/bad-socket.sock' | sudo tee /etc/default/kubelet > /dev/null

# Restart kubelet so it picks up the bad config
sudo systemctl daemon-reload
sudo systemctl restart kubelet || true

echo "Waiting for kubelet to fail..."
sleep 10

echo "[OK] Lab setup complete!"
echo "   - The kubelet has been configured with a wrong container runtime socket"
echo "   - The node will show NotReady"
echo "   - Check: systemctl status kubelet"
echo "   - Check: journalctl -u kubelet -n 50"
