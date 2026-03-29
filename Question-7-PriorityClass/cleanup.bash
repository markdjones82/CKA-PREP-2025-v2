#!/bin/bash
# Cleanup script for Question 7 - PriorityClass
set -uo pipefail
echo "Cleaning up Question 7: PriorityClass..."

kubectl delete deployment busybox-logger -n priority --ignore-not-found
kubectl delete namespace priority --ignore-not-found
kubectl delete priorityclass high-priority --ignore-not-found

echo "[OK] Question 7 cleanup complete"
