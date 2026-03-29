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
  kubectl get deployment wordpress

# 2. Deployment is available
check "WordPress deployment has available replicas" \
  bash -c '[[ $(kubectl get deployment wordpress -o jsonpath="{.status.availableReplicas}" 2>/dev/null) -ge 1 ]]'

# 3. Init container (sidecar) named init-logs or sidecar exists with busybox:stable image
check "Sidecar/init container with busybox:stable image exists" \
  bash -c '
    INIT_IMAGES=$(kubectl get deployment wordpress -o jsonpath="{.spec.template.spec.initContainers[*].image}" 2>/dev/null)
    echo "$INIT_IMAGES" | grep -q "busybox:stable"
  '

# 4. The sidecar runs tail -f or tail -F on /var/log/wordpress.log
check "Sidecar runs tail on /var/log/wordpress.log" \
  bash -c '
    CMD=$(kubectl get deployment wordpress -o json | grep -A5 "busybox:stable" | tr -d "\n")
    INIT_JSON=$(kubectl get deployment wordpress -o json)
    echo "$INIT_JSON" | grep -q "wordpress.log"
  '

# 5. Shared volume exists (emptyDir)
check "Shared emptyDir volume configured" \
  bash -c '
    kubectl get deployment wordpress -o json | python3 -c "
import json,sys
d=json.load(sys.stdin)
vols=d[\"spec\"][\"template\"][\"spec\"].get(\"volumes\",[])
assert any(\"emptyDir\" in v for v in vols)
"'

# 6. Volume mounted at /var/log on main container
check "Volume mounted at /var/log on main container" \
  bash -c '
    kubectl get deployment wordpress -o json | python3 -c "
import json,sys
d=json.load(sys.stdin)
containers=d[\"spec\"][\"template\"][\"spec\"][\"containers\"]
for c in containers:
  mounts=c.get(\"volumeMounts\",[])
  for m in mounts:
    if m[\"mountPath\"] == \"/var/log\":
      sys.exit(0)
sys.exit(1)
"'

# 7. Volume mounted at /var/log on sidecar/init container
check "Volume mounted at /var/log on sidecar init container" \
  bash -c '
    kubectl get deployment wordpress -o json | python3 -c "
import json,sys
d=json.load(sys.stdin)
inits=d[\"spec\"][\"template\"][\"spec\"].get(\"initContainers\",[])
for c in inits:
  mounts=c.get(\"volumeMounts\",[])
  for m in mounts:
    if m[\"mountPath\"] == \"/var/log\":
      sys.exit(0)
sys.exit(1)
"'

# 8. Pod is running
check "WordPress pod is Running" \
  bash -c 'kubectl get pods -l app=wordpress -o jsonpath="{.items[0].status.phase}" | grep -q Running'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
