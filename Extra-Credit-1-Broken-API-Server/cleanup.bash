#!/bin/bash
# Cleanup script for Extra Credit 1 - Broken API Server
set -uo pipefail
echo "Cleaning up Extra Credit 1: Broken API Server..."

# Restore the backup if it exists
if [[ -f /root/kube-apiserver.yaml.bak ]]; then
  sudo cp /root/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml
  echo "Restored kube-apiserver manifest from backup"
  sleep 15
else
  echo "No backup found at /root/kube-apiserver.yaml.bak"
fi

echo "[OK] Extra Credit 1 cleanup complete"
