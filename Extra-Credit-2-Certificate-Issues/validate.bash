#!/bin/bash
# Validation script for Extra Credit 2 - Certificate Issues
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
echo " Validating Extra Credit 2: Certificate Issues"
echo "======================================"

# 1. API server certificate exists
check "API server certificate file exists" \
  bash -c 'test -f /etc/kubernetes/pki/apiserver.crt'

# 2. Certificate CN is NOT bad-apiserver
check "API server cert CN is not bad-apiserver" \
  bash -c '
    CN=$(sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -subject 2>/dev/null)
    ! echo "$CN" | grep -q "bad-apiserver"
  '

# 3. Certificate is not expired
check "API server certificate is not expired" \
  bash -c 'sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -checkend 0 2>/dev/null'

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
