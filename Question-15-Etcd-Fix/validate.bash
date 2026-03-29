#!/bin/bash
# Validation script for Question 15 - Etcd Fix
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
echo " Validating Question 15: Etcd Fix"
echo "======================================"

# 1. kube-apiserver pod is running
check "kube-apiserver pod is Running" \
  bash -c 'kubectl get pods -n kube-system --no-headers 2>/dev/null | grep kube-apiserver | grep -q Running'

# 2. etcd endpoint uses port 2379 (not 2380)
check "kube-apiserver --etcd-servers uses port 2379" \
  bash -c '
    ETCD_SERVERS=$(grep -oP "(?<=--etcd-servers=)\S+" /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null || \
                   kubectl get pod -n kube-system -l component=kube-apiserver -o jsonpath="{.items[0].spec.containers[0].command}" 2>/dev/null | grep -oP "(?<=--etcd-servers=)\S+")
    echo "$ETCD_SERVERS" | grep -q ":2379"
  '

# 3. etcd endpoint does NOT use port 2380
check "kube-apiserver --etcd-servers does NOT use port 2380" \
  bash -c '
    ETCD_SERVERS=$(grep -oP "(?<=--etcd-servers=)\S+" /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null || echo "")
    ! echo "$ETCD_SERVERS" | grep -q ":2380"
  '

# 4. kubectl can communicate with the cluster
check "kubectl can communicate with cluster (get nodes works)" \
  kubectl get nodes

# 5. etcd pod is running
check "etcd pod is Running" \
  bash -c 'kubectl get pods -n kube-system --no-headers 2>/dev/null | grep etcd | grep -q Running'

# 6. kube-scheduler is running
check "kube-scheduler pod is Running" \
  bash -c 'kubectl get pods -n kube-system --no-headers 2>/dev/null | grep kube-scheduler | grep -q Running'

# 7. All control plane components healthy
check "All control plane pods are Running" \
  bash -c '
    FAILED=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -E "kube-apiserver|kube-scheduler|kube-controller-manager|etcd" | grep -v Running | wc -l)
    [[ "$FAILED" -eq 0 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
