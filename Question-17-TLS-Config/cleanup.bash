#!/bin/bash
# Cleanup script for Question 17 - TLS Config
set -uo pipefail
echo "Cleaning up Question 17: TLS Config..."

kubectl delete deployment -n nginx-static --all --ignore-not-found
kubectl delete service nginx-service -n nginx-static --ignore-not-found
kubectl delete configmap nginx-config -n nginx-static --ignore-not-found
kubectl delete secret -n nginx-static --all --ignore-not-found
kubectl delete namespace nginx-static --ignore-not-found

# Remove /etc/hosts entry for ckaquestion.k8s.local
sudo sed -i '/ckaquestion.k8s.local/d' /etc/hosts

echo "[OK] Question 17 cleanup complete"
