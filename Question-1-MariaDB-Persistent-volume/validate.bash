#!/bin/bash
# Validation script for Question 1 - MariaDB Persistent Volume
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
echo " Validating Question 1: MariaDB PV"
echo "======================================"

# 1. PVC named mariadb exists in mariadb namespace
check "PVC 'mariadb' exists in namespace 'mariadb'" \
  kubectl get pvc mariadb -n mariadb

# 2. PVC access mode is ReadWriteOnce
check "PVC access mode is ReadWriteOnce" \
  bash -c '[[ "$(kubectl get pvc mariadb -n mariadb -o jsonpath="{.spec.accessModes[0]}")" == "ReadWriteOnce" ]]'

# 3. PVC storage request is 250Mi
check "PVC storage request is 250Mi" \
  bash -c '[[ "$(kubectl get pvc mariadb -n mariadb -o jsonpath="{.spec.resources.requests.storage}")" == "250Mi" ]]'

# 4. PVC is Bound
check "PVC is in Bound state" \
  bash -c '[[ "$(kubectl get pvc mariadb -n mariadb -o jsonpath="{.status.phase}")" == "Bound" ]]'

# 5. PV mariadb-pv is Bound
check "PV 'mariadb-pv' is Bound" \
  bash -c '[[ "$(kubectl get pv mariadb-pv -o jsonpath="{.status.phase}")" == "Bound" ]]'

# 6. Deployment mariadb exists in mariadb namespace
check "Deployment 'mariadb' exists in namespace 'mariadb'" \
  kubectl get deployment mariadb -n mariadb

# 7. Deployment references the PVC mariadb
check "Deployment uses PVC 'mariadb'" \
  bash -c '[[ "$(kubectl get deployment mariadb -n mariadb -o jsonpath="{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}")" == "mariadb" ]]'

# 8. Deployment is available (at least 1 ready replica)
check "Deployment has at least 1 available replica" \
  bash -c '[[ $(kubectl get deployment mariadb -n mariadb -o jsonpath="{.status.availableReplicas}") -ge 1 ]]'

# 9. Pod is Running
check "MariaDB pod is Running" \
  bash -c 'kubectl get pods -n mariadb -l app=mariadb -o jsonpath="{.items[0].status.phase}" | grep -q Running'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
