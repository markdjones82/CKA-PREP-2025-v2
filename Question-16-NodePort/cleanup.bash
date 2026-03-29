#!/bin/bash
# Cleanup script for Question 16 - NodePort
set -uo pipefail
echo "Cleaning up Question 16: NodePort..."

kubectl delete service nodeport-service -n relative --ignore-not-found
kubectl delete deployment nodeport-deployment -n relative --ignore-not-found
kubectl delete namespace relative --ignore-not-found
rm -f ~/svc.yaml

echo "[OK] Question 16 cleanup complete"
