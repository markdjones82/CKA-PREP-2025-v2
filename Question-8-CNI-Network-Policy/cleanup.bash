#!/bin/bash
# Cleanup script for Question 8 - CNI & Network Policy
set -uo pipefail
echo "Cleaning up Question 8: CNI & Network Policy..."

# Remove Calico/tigera-operator if installed
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml 2>/dev/null || true
kubectl delete namespace tigera-operator --ignore-not-found
kubectl delete namespace calico-system --ignore-not-found

# Remove Flannel if installed
kubectl delete namespace kube-flannel --ignore-not-found

echo "[OK] Question 8 cleanup complete"
echo "NOTE: CNI removal may require a node restart to fully take effect."
