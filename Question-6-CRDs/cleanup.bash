#!/bin/bash
# Cleanup script for Question 6 - CRDs (cert-manager)
set -uo pipefail
echo "Cleaning up Question 6: CRDs (cert-manager)..."

kubectl delete deployment cert-manager -n cert-manager --ignore-not-found
kubectl delete namespace cert-manager --ignore-not-found
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.crds.yaml 2>/dev/null || true
rm -f /root/resources.yaml /root/subject.yaml

echo "[OK] Question 6 cleanup complete"
