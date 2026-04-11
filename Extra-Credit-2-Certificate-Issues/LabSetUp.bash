#!/bin/bash
set -Eeuo pipefail

trap 'echo "[ERROR] Lab setup failed at line $LINENO: $BASH_COMMAND" >&2' ERR

echo "Setting up Extra Credit 2: Certificate Issues..."

# Backup original certs
sudo cp /etc/kubernetes/pki/apiserver.crt /root/apiserver.crt.bak
sudo cp /etc/kubernetes/pki/apiserver.key /root/apiserver.key.bak

# Generate an expired self-signed cert to replace the API server cert
sudo openssl req -x509 \
  -newkey rsa:2048 \
  -keyout /etc/kubernetes/pki/apiserver.key \
  -out /etc/kubernetes/pki/apiserver.crt \
  -days 0 \
  -nodes \
  -subj "/CN=bad-apiserver" \
  2>/dev/null

echo "Waiting for kubelet to detect certificate change..."
sleep 10

# Force the API server pod to restart by touching the manifest
sudo touch /etc/kubernetes/manifests/kube-apiserver.yaml
sleep 5

echo "[OK] Lab setup complete!"
echo "   - The API server certificate has been replaced with an expired/invalid one"
echo "   - kubectl commands will fail with TLS errors"
echo "   - Check certs with: openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout"
echo "   - Use kubeadm to fix: kubeadm certs renew apiserver"
