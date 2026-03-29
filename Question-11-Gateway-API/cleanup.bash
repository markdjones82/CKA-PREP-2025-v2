#!/bin/bash
# Cleanup script for Question 11 - Gateway API
set -uo pipefail
echo "Cleaning up Question 11: Gateway API..."

kubectl delete httproute web-route --ignore-not-found
kubectl delete gateway web-gateway --ignore-not-found
kubectl delete gatewayclass nginx-class --ignore-not-found
kubectl delete ingress web --ignore-not-found
kubectl delete secret web-tls --ignore-not-found
kubectl delete service web-service --ignore-not-found
kubectl delete deployment web-deployment --ignore-not-found
rm -f ~/gw.yaml ~/http.yaml

echo "[OK] Question 11 cleanup complete"
echo "NOTE: Gateway API CRDs are left in place as they are cluster-wide."
