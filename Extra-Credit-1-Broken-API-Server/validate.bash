#!/bin/bash
# Validation script for Extra Credit 1 - Broken API Server
set -uo pipefail

PASS=0
FAIL=0
TOTAL=0

check() {
  local description="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "======================================"
echo " Validating Extra Credit 1: Broken API Server"
echo "======================================"

# 1. kube-apiserver manifest exists
check "kube-apiserver manifest exists" \
  bash -c 'test -f /etc/kubernetes/manifests/kube-apiserver.yaml'

# 2. service-cluster-ip-range is NOT the broken value
check "service-cluster-ip-range is not 999.999.0.0/16" \
  bash -c '! grep -q "999.999.0.0/16" /etc/kubernetes/manifests/kube-apiserver.yaml'

# 3. service-cluster-ip-range is a valid CIDR
check "service-cluster-ip-range is a valid CIDR" \
  bash -c 'grep -q "service-cluster-ip-range=10\." /etc/kubernetes/manifests/kube-apiserver.yaml'

# 4. kube-apiserver pod is running
check "kube-apiserver pod is Running" \
  bash -c 'kubectl get pods -n kube-system --no-headers 2>/dev/null | grep kube-apiserver | grep -q Running'

# 5. kubectl can communicate with the cluster
check "kubectl get nodes works" \
  kubectl get nodes

# 6. All control plane pods are running
check "All control plane pods are Running" \
  bash -c '
    FAILED=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -E "kube-apiserver|kube-scheduler|kube-controller-manager|etcd" | grep -v Running | wc -l)
    [[ "$FAILED" -eq 0 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
