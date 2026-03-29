#!/bin/bash
# Validation script for Question 16 - NodePort
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
echo " Validating Question 16: NodePort"
echo "======================================"

# Detect the namespace (question says "relative namespace")
NS="relative"

# 1. Deployment nodeport-deployment exists
check "Deployment 'nodeport-deployment' exists in namespace '$NS'" \
  kubectl get deployment nodeport-deployment -n "$NS"

# 2. Deployment has containerPort 80 defined
check "Deployment has containerPort 80 configured" \
  bash -c '
    PORTS=$(kubectl get deployment nodeport-deployment -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].ports[*].containerPort}" 2>/dev/null)
    echo "$PORTS" | grep -q "80"
  '

# 3. Container port name is "http"
check "Container port name is 'http'" \
  bash -c '
    NAME=$(kubectl get deployment nodeport-deployment -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].ports[0].name}" 2>/dev/null)
    [[ "$NAME" == "http" ]]
  '

# 4. Container port protocol is TCP
check "Container port protocol is TCP" \
  bash -c '
    PROTO=$(kubectl get deployment nodeport-deployment -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].ports[0].protocol}" 2>/dev/null)
    [[ "$PROTO" == "TCP" ]]
  '

# 5. Service nodeport-service exists
check "Service 'nodeport-service' exists in namespace '$NS'" \
  kubectl get svc nodeport-service -n "$NS"

# 6. Service type is NodePort
check "Service type is NodePort" \
  bash -c '[[ "$(kubectl get svc nodeport-service -n '"$NS"' -o jsonpath="{.spec.type}")" == "NodePort" ]]'

# 7. Service port is 80
check "Service port is 80" \
  bash -c '
    PORT=$(kubectl get svc nodeport-service -n '"$NS"' -o jsonpath="{.spec.ports[0].port}" 2>/dev/null)
    [[ "$PORT" == "80" ]]
  '

# 8. Service targetPort is 80
check "Service targetPort is 80" \
  bash -c '
    TP=$(kubectl get svc nodeport-service -n '"$NS"' -o jsonpath="{.spec.ports[0].targetPort}" 2>/dev/null)
    [[ "$TP" == "80" ]]
  '

# 9. NodePort is 30080
check "Service nodePort is 30080" \
  bash -c '
    NP=$(kubectl get svc nodeport-service -n '"$NS"' -o jsonpath="{.spec.ports[0].nodePort}" 2>/dev/null)
    [[ "$NP" == "30080" ]]
  '

# 10. Service protocol is TCP
check "Service port protocol is TCP" \
  bash -c '
    PROTO=$(kubectl get svc nodeport-service -n '"$NS"' -o jsonpath="{.spec.ports[0].protocol}" 2>/dev/null)
    [[ "$PROTO" == "TCP" ]]
  '

# 11. Service has endpoints
check "Service has active endpoints" \
  bash -c '
    EP=$(kubectl get endpoints nodeport-service -n '"$NS"' -o jsonpath="{.subsets[0].addresses}" 2>/dev/null)
    [[ -n "$EP" && "$EP" != "[]" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
