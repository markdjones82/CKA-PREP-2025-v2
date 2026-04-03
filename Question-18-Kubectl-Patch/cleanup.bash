#!/bin/bash
# Cleanup script for Question 18 - kubectl patch
set -uo pipefail
echo "Cleaning up Question 18: kubectl patch..."

kubectl delete deployment resource-app -n patch-ns --ignore-not-found
kubectl delete namespace patch-ns --ignore-not-found

echo "[OK] Question 18 cleanup complete"
