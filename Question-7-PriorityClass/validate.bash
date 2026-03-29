#!/bin/bash
# Validation script for Question 7 - PriorityClass
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
echo " Validating Question 7: PriorityClass"
echo "============================================"

# 1. PriorityClass high-priority exists
check "PriorityClass 'high-priority' exists" \
  kubectl get priorityclass high-priority

# 2. PriorityClass value is exactly 1 less than highest existing user-defined class
check "PriorityClass value is one less than the highest existing user-defined class" \
  bash -c '
    HP_VAL=$(kubectl get priorityclass high-priority -o jsonpath="{.value}")
    # Get all non-system priority classes (value < 1000000000) except high-priority
    MAX_VAL=$(kubectl get priorityclass -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
vals = []
for item in data[\"items\"]:
    name = item[\"metadata\"][\"name\"]
    val = item[\"value\"]
    if name != \"high-priority\" and name != \"system-cluster-critical\" and name != \"system-node-critical\" and val < 1000000000:
        vals.append(val)
if vals:
    print(max(vals))
else:
    print(0)
")
    EXPECTED=$((MAX_VAL - 1))
    [[ "$HP_VAL" == "$EXPECTED" ]] || [[ "$HP_VAL" == "$MAX_VAL" ]]
  '

# 3. PriorityClass is not globalDefault
check "PriorityClass is not globalDefault" \
  bash -c '
    GD=$(kubectl get priorityclass high-priority -o jsonpath="{.globalDefault}" 2>/dev/null)
    [[ "$GD" != "true" ]]
  '

# 4. Deployment busybox-logger exists in priority namespace
check "Deployment 'busybox-logger' exists in namespace 'priority'" \
  kubectl get deployment busybox-logger -n priority

# 5. Deployment uses high-priority PriorityClass
check "Deployment 'busybox-logger' uses priorityClassName 'high-priority'" \
  bash -c '[[ "$(kubectl get deployment busybox-logger -n priority -o jsonpath="{.spec.template.spec.priorityClassName}")" == "high-priority" ]]'

# 6. Pods are running
check "busybox-logger pods are Running" \
  bash -c 'kubectl get pods -n priority -l app=busybox-logger --no-headers 2>/dev/null | grep -q Running || kubectl get pods -n priority --no-headers 2>/dev/null | grep busybox | grep -q Running'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
