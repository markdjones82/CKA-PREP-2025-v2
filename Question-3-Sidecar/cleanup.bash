#!/bin/bash
# Cleanup script for Question 3 - Sidecar
set -uo pipefail
echo "Cleaning up Question 3: Sidecar..."

kubectl delete deployment wordpress -n default --ignore-not-found
kubectl delete service wordpress -n default --ignore-not-found 2>/dev/null || true

echo "[OK] Question 3 cleanup complete"
