#!/bin/bash
# Validation script for Extra Credit 4 - Pod Resource Limits and Reservations
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
echo " Validating Extra Credit 4: Pod Limits & Reservations"
echo "======================================"

NS="resource-lab"

# 1. Namespace exists
check "Namespace '$NS' exists" \
  kubectl get ns "$NS"

# 2. Deployment exists with 3 replicas
check "Deployment web-app exists with 3 replicas" \
  bash -c '[[ $(kubectl get deployment web-app -n '"$NS"' -o jsonpath="{.spec.replicas}" 2>/dev/null) -eq 3 ]]'

# 3. CPU request is set to 200m
check "CPU request is 200m" \
  bash -c '
    REQ=$(kubectl get deployment web-app -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    [[ "$REQ" == "200m" ]]
  '

# 4. Memory request is set to 256Mi
check "Memory request is 256Mi" \
  bash -c '
    REQ=$(kubectl get deployment web-app -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    [[ "$REQ" == "256Mi" ]]
  '

# 5. CPU limit is set to 500m
check "CPU limit is 500m" \
  bash -c '
    LIM=$(kubectl get deployment web-app -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    [[ "$LIM" == "500m" ]]
  '

# 6. Memory limit is set to 512Mi
check "Memory limit is 512Mi" \
  bash -c '
    LIM=$(kubectl get deployment web-app -n '"$NS"' -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    [[ "$LIM" == "512Mi" ]]
  '

# 7. LimitRange exists
check "LimitRange exists in namespace '$NS'" \
  bash -c 'kubectl get limitrange -n '"$NS"' --no-headers 2>/dev/null | grep -q "."'

# 8. LimitRange max CPU is 1
check "LimitRange max CPU is 1" \
  bash -c '
    MAX=$(kubectl get limitrange -n '"$NS"' -o jsonpath="{.items[0].spec.limits[0].max.cpu}" 2>/dev/null)
    [[ "$MAX" == "1" ]]
  '

# 9. ResourceQuota exists
check "ResourceQuota exists in namespace '$NS'" \
  bash -c 'kubectl get resourcequota -n '"$NS"' --no-headers 2>/dev/null | grep -q "."'

# 10. ResourceQuota requests.cpu is 2
check "ResourceQuota requests.cpu is 2" \
  bash -c '
    HARD=$(kubectl get resourcequota -n '"$NS"' -o jsonpath="{.items[0].spec.hard.requests\.cpu}" 2>/dev/null)
    [[ "$HARD" == "2" ]]
  '

# 11. All pods are running
check "All web-app pods are Running" \
  bash -c '
    RUNNING=$(kubectl get pods -n '"$NS"' -l app=web-app --no-headers 2>/dev/null | grep Running | wc -l)
    [[ "$RUNNING" -eq 3 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
