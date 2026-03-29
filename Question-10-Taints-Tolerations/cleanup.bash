#!/bin/bash
# Cleanup script for Question 10 - Taints & Tolerations
set -uo pipefail
echo "Cleaning up Question 10: Taints & Tolerations..."

# Remove taint from node01
kubectl taint nodes node01 PERMISSION=granted:NoSchedule- 2>/dev/null || true

# Delete pods created for this question
kubectl delete pod nginx nginx-fail --ignore-not-found

echo "[OK] Question 10 cleanup complete"
