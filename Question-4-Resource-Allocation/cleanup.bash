#!/bin/bash
# Cleanup script for Question 4 - Resource Allocation
set -uo pipefail
echo "Cleaning up Question 4: Resource Allocation..."

kubectl delete deployment wordpress --ignore-not-found
kubectl delete service wordpress --ignore-not-found 2>/dev/null || true

echo "[OK] Question 4 cleanup complete"
