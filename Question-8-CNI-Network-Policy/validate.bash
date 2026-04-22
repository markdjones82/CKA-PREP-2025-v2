#!/bin/bash
# Validation script for Question 8 - CNI & Network Policy
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

echo "============================================"
echo " Validating Question 8: CNI & Network Policy"
echo "============================================"

# 1. A CNI is installed (check for calico pods)
check "CNI plugin is installed (calico pods running)" \
  bash -c '
    kubectl get pods -A --no-headers 2>/dev/null | grep -qiE "calico|tigera"
  '

# 2. All nodes are Ready (CNI is working)
check "All nodes are in Ready state" \
  bash -c '
    NOT_READY=$(kubectl get nodes --no-headers 2>/dev/null | grep -v " Ready " | wc -l)
    [[ "$NOT_READY" -eq 0 ]]
  '

# 3. Pods can communicate (kube-dns is working as a proxy check)
check "CoreDNS pods are Running (pod networking functional)" \
  bash -c '
    kubectl get pods -n kube-system --no-headers 2>/dev/null | grep coredns | grep -q Running
  '

# 4. CNI supports NetworkPolicy (Calico/Tigera detected)
check "CNI supports NetworkPolicy (Calico/Tigera detected)" \
  bash -c '
    # Calico supports NetworkPolicy; Flannel does not natively
    kubectl get pods -A --no-headers 2>/dev/null | grep -qiE "calico|tigera"
  '

# 5. CNI was installed from manifest (tigera-operator or calico namespace exists)
check "CNI installed from manifest (tigera-operator or calico namespace)" \
  bash -c '
    kubectl get ns --no-headers 2>/dev/null | grep -qiE "tigera|calico"
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
