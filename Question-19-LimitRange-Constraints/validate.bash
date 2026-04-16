#!/bin/bash
# Validation script for Question 19 - WordPress Pod Scheduling

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

echo "==========================================="
echo " Validating Question 19: WordPress Scheduling"
echo "==========================================="

# 1. Namespace exists
check "Namespace 'relative-fawn' exists" \
  kubectl get namespace relative-fawn

# 2. WordPress deployment exists
check "Deployment 'wordpress' exists in relative-fawn" \
  kubectl get deployment wordpress -n relative-fawn

# 3. WordPress has 3 replicas configured
check "WordPress deployment has 3 replicas" \
  bash -c '[[ "$(kubectl get deployment wordpress -n relative-fawn -o jsonpath="{.spec.replicas}")" == "3" ]]'

# 4. All 3 WordPress pods are Running
check "All 3 WordPress pods are Running" \
  bash -c '[[ $(kubectl get pods -n relative-fawn -l app=wordpress --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l) -eq 3 ]]'

# 5. No Pending pods in the namespace
check "No Pending pods in relative-fawn" \
  bash -c '[[ $(kubectl get pods -n relative-fawn --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l) -eq 0 ]]'

# 6. Monitoring-agent is still running
check "Monitoring-agent deployment still exists and running" \
  bash -c '[[ $(kubectl get pods -n relative-fawn -l app=monitoring-agent --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l) -ge 1 ]]'

# 7. WordPress pods have CPU requests set
check "WordPress container has CPU requests defined" \
  bash -c '
    REQ=$(kubectl get deployment wordpress -n relative-fawn -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    [[ -n "$REQ" && "$REQ" != "0" ]]
  '

# 8. WordPress CPU requests were increased from 100m (properly sized)
check "WordPress CPU request was increased (greater than 100m)" \
  bash -c '
    REQ=$(kubectl get deployment wordpress -n relative-fawn -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    VAL=${REQ%m}
    [[ ${VAL:-0} -gt 100 ]]
  '

# 9. WordPress memory requests were increased from 100Mi (properly sized)
check "WordPress memory request was increased (greater than 100Mi)" \
  bash -c '
    REQ=$(kubectl get deployment wordpress -n relative-fawn -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    VAL=${REQ%Mi}
    [[ ${VAL:-0} -gt 100 ]]
  '

# 10. Limits were NOT modified (still 300m CPU)
check "WordPress CPU limit unchanged (still 300m)" \
  bash -c '
    LIM=$(kubectl get deployment wordpress -n relative-fawn -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    VAL=${LIM%m}
    [[ ${VAL:-0} -eq 300 ]]
  '

echo ""
echo "==========================================="
echo " Summary"
echo "==========================================="
echo "  Passed: $PASS/$TOTAL"
echo "  Failed: $FAIL/$TOTAL"
echo "==========================================="

if [ $FAIL -eq 0 ]; then
  echo "  Result: SUCCESS"
  exit 0
else
  echo "  Result: FAILURE"
  exit 1
fi

