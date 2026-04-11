#!/bin/bash
# Validation script for Extra Credit 3 - Kubelet Not Starting
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
echo " Validating Extra Credit 3: Kubelet Not Starting"
echo "======================================"

# 1. Kubelet service is active on node01
check "Kubelet service is active on node01" \
  bash -c 'ssh node01 "systemctl is-active kubelet"'

# 2. Kubelet is not using bad socket on node01
check "kubeadm-flags.env does not contain the typo container.sock" \
  bash -c '! ssh node01 "grep -q container-runtime-endpoint=unix:///run/containerd/container.sock /var/lib/kubelet/kubeadm-flags.env 2>/dev/null"'

# 3. node01 is Ready
check "node01 is in Ready state" \
  bash -c '
    kubectl get node node01 --no-headers 2>/dev/null | grep -v NotReady | grep -q Ready
  '

# 4. kubectl can communicate with the cluster
check "kubectl get nodes works" \
  kubectl get nodes

# 5. All kube-system pods are running
check "kube-system pods are Running" \
  bash -c '
    FAILED=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -v Running | grep -v Completed | wc -l)
    [[ "$FAILED" -eq 0 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
