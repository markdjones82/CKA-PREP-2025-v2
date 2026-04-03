#!/bin/bash
# Cleanup script for Extra Credit 2 - Certificate Issues
set -uo pipefail
echo "Cleaning up Extra Credit 2: Certificate Issues..."

# Restore original certs if backups exist
if [[ -f /root/apiserver.crt.bak ]]; then
  sudo cp /root/apiserver.crt.bak /etc/kubernetes/pki/apiserver.crt
  sudo cp /root/apiserver.key.bak /etc/kubernetes/pki/apiserver.key
  echo "Restored API server certificate from backup"
  # Restart the API server
  sudo touch /etc/kubernetes/manifests/kube-apiserver.yaml
  sleep 15
else
  echo "No backup found. Run: sudo kubeadm certs renew apiserver"
fi

echo "[OK] Extra Credit 2 cleanup complete"
