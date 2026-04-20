#!/bin/bash
# Validation script for Question 3 - Sidecar Container
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
echo " Validating Question 3: Sidecar"
echo "======================================"

# 1. Deployment wordpress exists
check "Deployment 'wordpress' exists" \
  bash -c 'kubectl get deployment wordpress -n default -o name | grep -q "^deployment.apps/wordpress$"'

# 2. Deployment is available
check "WordPress deployment has available replicas" \
  bash -c '[[ $(kubectl get deployment wordpress -n default -o jsonpath="{.status.availableReplicas}" 2>/dev/null) -ge 1 ]]'

# 3. Sidecar container named sidecar exists with busybox:stable image
check "Sidecar container named sidecar exists" \
  bash -c '
    IMG=$(kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.containers[?(@.name==\"sidecar\")].image}{.spec.template.spec.initContainers[?(@.name==\"sidecar\")].image}" 2>/dev/null)
    [[ "$IMG" == "busybox:stable" ]]
  '

# 4. The sidecar runs tail -f or tail -F on /var/log/wordpress.log
check "Sidecar runs tail on /var/log/wordpress.log" \
  bash -c '
    CMD=$(kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.containers[?(@.name==\"sidecar\")].command[*]}" 2>/dev/null)
    if [[ -z "$CMD" ]]; then
      CMD=$(kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.initContainers[?(@.name==\"sidecar\")].command[*]}" 2>/dev/null)
    fi
    [[ "$CMD" == *"tail"* && "$CMD" == *"wordpress.log"* ]]
  '

# 5. Shared volume exists (emptyDir) - volume name can be anything
check "Shared emptyDir volume configured" \
  bash -c '
    kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.volumes[?(@.emptyDir)].name}" | grep -q "."
  '

# 6. Volume mounted at /var/log on main container
check "Volume mounted at /var/log on main container" \
  bash -c '
    kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.containers[?(@.name==\"wordpress\")].volumeMounts[?(@.mountPath==\"/var/log\")].mountPath}" | grep -q "^/var/log$"
  '

# 7. Volume mounted at /var/log on sidecar or init container
check "Volume mounted at /var/log on sidecar" \
  bash -c '
    MOUNT=$(kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.containers[?(@.name==\"sidecar\")].volumeMounts[?(@.mountPath==\"/var/log\")].mountPath}" 2>/dev/null)
    if [[ -z "$MOUNT" ]]; then
      MOUNT=$(kubectl get deployment wordpress -n default -o jsonpath="{.spec.template.spec.initContainers[?(@.name==\"sidecar\")].volumeMounts[?(@.mountPath==\"/var/log\")].mountPath}" 2>/dev/null)
    fi
    [[ "$MOUNT" == "/var/log" ]]
  '

# 8. WordPress log line exists in the shared volume
check "WordPress log line is written to shared volume" \
  bash -c '
    POD=$(kubectl get pods -n default -l app=wordpress -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
    [[ -n "$POD" ]] || exit 1
    kubectl exec "$POD" -n default -c wordpress -- sh -c "grep -q \"WordPress is running...\" /var/log/wordpress.log"
  '

# 9. Pod is running
check "WordPress pod is Running" \
  bash -c 'kubectl get pods -n default -l app=wordpress -o jsonpath="{.items[0].status.phase}" | grep -q "^Running$"'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
