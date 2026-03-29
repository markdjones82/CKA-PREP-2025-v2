#!/bin/bash
# Cleanup script for Question 5 - HPA
set -uo pipefail
echo "Cleaning up Question 5: HPA..."

kubectl delete hpa apache-server -n autoscale --ignore-not-found
kubectl delete deployment apache-deployment -n autoscale --ignore-not-found
kubectl delete service apache-deployment -n autoscale --ignore-not-found
kubectl delete namespace autoscale --ignore-not-found
kubectl delete deployment metrics-server -n kube-system --ignore-not-found
rm -f ~/hpa.yaml

echo "[OK] Question 5 cleanup complete"
