#!/bin/bash
# Validation script for Question 2 – ArgoCD Helm Template
set -uo pipefail

PASS=0
FAIL=0
TOTAL=0

check() {
  local description="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  ❌ FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "======================================"
echo " Validating Question 2: ArgoCD"
echo "======================================"

# 1. Namespace argocd exists
check "Namespace 'argocd' exists" \
  kubectl get namespace argocd

# 2. Helm repo argocd exists
check "Helm repo 'argocd' is added" \
  bash -c 'helm repo list 2>/dev/null | grep -q "argocd"'

# 3. Helm repo points to correct URL
check "Helm repo URL is correct (argoproj.github.io/argo-helm)" \
  bash -c 'helm repo list 2>/dev/null | grep argocd | grep -q "https://argoproj.github.io/argo-helm"'

# 4. /root/argo-helm.yaml exists
check "File /root/argo-helm.yaml exists" \
  test -f /root/argo-helm.yaml

# 5. /root/argo-helm.yaml is not empty
check "File /root/argo-helm.yaml is not empty" \
  test -s /root/argo-helm.yaml

# 6. The generated manifest references argocd namespace
check "Manifest references argocd namespace" \
  bash -c 'grep -q "namespace.*argocd\|argocd" /root/argo-helm.yaml'

# 7. No CRD resources in the generated YAML
check "No CRD kind in generated manifest (CRDs skipped)" \
  bash -c '! grep -q "kind: CustomResourceDefinition" /root/argo-helm.yaml'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
