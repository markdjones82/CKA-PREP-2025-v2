#!/bin/bash
# Cleanup script for Question 2 - ArgoCD
set -uo pipefail
echo "Cleaning up Question 2: ArgoCD..."

helm uninstall argocd -n argocd 2>/dev/null || true
kubectl delete namespace argocd --ignore-not-found
helm repo remove argocd 2>/dev/null || true
rm -f /root/argo-helm.yaml ~/argo-helm.yaml

echo "[OK] Question 2 cleanup complete"
