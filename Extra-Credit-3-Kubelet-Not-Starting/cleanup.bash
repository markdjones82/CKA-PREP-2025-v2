#!/bin/bash
# Cleanup script for Extra Credit 3 - Kubelet Not Starting
set -uo pipefail
echo "Cleaning up Extra Credit 3: Kubelet Not Starting..."

# Restore the original kubeadm-flags.env from the backup taken during setup
if ssh node01 "test -f /root/kubeadm-flags.env.bak"; then
  ssh node01 "sudo cp /root/kubeadm-flags.env.bak /var/lib/kubelet/kubeadm-flags.env"
else
  echo "[WARN] No kubeadm-flags.env backup found on node01. Kubelet may have been manually fixed already."
fi

ssh node01 "sudo systemctl daemon-reload"
ssh node01 "sudo systemctl restart kubelet"
sleep 15

echo "[OK] Extra Credit 3 cleanup complete"
