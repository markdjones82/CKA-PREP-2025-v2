#!/bin/bash
# Cleanup script for Question 14 - Storage Class
set -uo pipefail
echo "Cleaning up Question 14: Storage Class..."

# Remove default annotation from local-storage before deleting
kubectl patch storageclass local-storage \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' 2>/dev/null || true
kubectl delete storageclass local-storage --ignore-not-found
rm -f ~/sc.yaml

echo "[OK] Question 14 cleanup complete"
