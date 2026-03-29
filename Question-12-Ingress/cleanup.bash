#!/bin/bash
# Cleanup script for Question 12 - Ingress
set -uo pipefail
echo "Cleaning up Question 12: Ingress..."

kubectl delete ingress echo -n echo-sound --ignore-not-found
kubectl delete service echo-service -n echo-sound --ignore-not-found
kubectl delete deployment echo -n echo-sound --ignore-not-found
kubectl delete namespace echo-sound --ignore-not-found
rm -f ~/ingress.yaml

echo "[OK] Question 12 cleanup complete"
