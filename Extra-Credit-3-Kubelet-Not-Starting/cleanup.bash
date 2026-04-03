#!/bin/bash
# Cleanup script for Extra Credit 3 - Kubelet Not Starting
set -uo pipefail
echo "Cleaning up Extra Credit 3: Kubelet Not Starting..."

# Remove the bad kubelet extra args
echo 'KUBELET_EXTRA_ARGS=' | sudo tee /etc/default/kubelet > /dev/null

# Restore backup if it exists
if [[ -f /root/10-kubeadm.conf.bak ]]; then
  sudo cp /root/10-kubeadm.conf.bak /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sleep 15

echo "[OK] Extra Credit 3 cleanup complete"
