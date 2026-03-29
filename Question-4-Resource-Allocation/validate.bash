#!/bin/bash
# Validation script for Question 4 - Resource Allocation
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
echo " Validating Question 4: Resource Allocation"
echo "==========================================="

# 1. Deployment wordpress exists
check "Deployment 'wordpress' exists" \
  kubectl get deployment wordpress

# 2. Deployment is scaled to 3 replicas
check "Deployment has 3 replicas" \
  bash -c '[[ "$(kubectl get deployment wordpress -o jsonpath="{.spec.replicas}")" == "3" ]]'

# 3. All 3 pods are available
check "All 3 replicas are available" \
  bash -c '[[ $(kubectl get deployment wordpress -o jsonpath="{.status.availableReplicas}" 2>/dev/null) -ge 3 ]]'

# 4. Main containers have resource requests defined
check "Main containers have CPU requests set" \
  bash -c '
    REQ=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    [[ -n "$REQ" ]]
  '

check "Main containers have memory requests set" \
  bash -c '
    REQ=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    [[ -n "$REQ" ]]
  '

# 5. Main containers have resource limits defined
check "Main containers have CPU limits set" \
  bash -c '
    LIM=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    [[ -n "$LIM" ]]
  '

check "Main containers have memory limits set" \
  bash -c '
    LIM=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    [[ -n "$LIM" ]]
  '

# 6. Init containers (if any) have the same resources as main containers
check "Init containers have matching resource requests/limits (if present)" \
  bash -c '
    INIT_CPU_REQ=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.initContainers[0].resources.requests.cpu}" 2>/dev/null)
    MAIN_CPU_REQ=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    # If no init containers, pass
    if [[ -z "$INIT_CPU_REQ" ]]; then exit 0; fi
    [[ "$INIT_CPU_REQ" == "$MAIN_CPU_REQ" ]]
  '

# 7. All pods are Running
check "All wordpress pods are Running" \
  bash -c '
    RUNNING=$(kubectl get pods -l app=wordpress --no-headers 2>/dev/null | grep -c Running)
    [[ $RUNNING -ge 3 ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
