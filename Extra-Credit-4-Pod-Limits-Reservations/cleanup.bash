#!/bin/bash
# Cleanup script for Extra Credit 4 - Pod Resource Limits and Reservations
set -uo pipefail
echo "Cleaning up Extra Credit 4: Pod Resource Limits and Reservations..."

NS="resource-lab"

kubectl delete namespace "$NS" --ignore-not-found
echo "Waiting for namespace deletion..."
kubectl wait --for=delete namespace/"$NS" --timeout=60s 2>/dev/null || true

echo "[OK] Extra Credit 4 cleanup complete"
