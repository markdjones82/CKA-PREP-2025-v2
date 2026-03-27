#!/bin/bash
# Validation script for Question 10 – Taints & Tolerations
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

echo "============================================="
echo " Validating Question 10: Taints & Tolerations"
echo "============================================="

# 1. node01 has the taint PERMISSION=granted:NoSchedule
check "node01 has taint PERMISSION=granted:NoSchedule" \
  bash -c '
    kubectl describe node node01 2>/dev/null | grep -q "PERMISSION=granted:NoSchedule"
  '

# 2. A pod exists that tolerates the taint and is scheduled on node01
check "A pod with toleration for PERMISSION=granted:NoSchedule exists" \
  bash -c '
    # Check all pods for the toleration
    kubectl get pods -A -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pod in data[\"items\"]:
    ns = pod[\"metadata\"][\"namespace\"]
    if ns.startswith(\"kube-\"):
        continue
    tolerations = pod[\"spec\"].get(\"tolerations\", [])
    for t in tolerations:
        if t.get(\"key\") == \"PERMISSION\" and t.get(\"value\") == \"granted\" and t.get(\"effect\") == \"NoSchedule\":
            sys.exit(0)
sys.exit(1)
"'

# 3. The tolerating pod is Running
check "Tolerating pod is in Running state" \
  bash -c '
    kubectl get pods -A -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pod in data[\"items\"]:
    ns = pod[\"metadata\"][\"namespace\"]
    if ns.startswith(\"kube-\"):
        continue
    tolerations = pod[\"spec\"].get(\"tolerations\", [])
    for t in tolerations:
        if t.get(\"key\") == \"PERMISSION\" and t.get(\"value\") == \"granted\" and t.get(\"effect\") == \"NoSchedule\":
            if pod[\"status\"][\"phase\"] == \"Running\":
                sys.exit(0)
sys.exit(1)
"'

# 4. The tolerating pod is on node01
check "Tolerating pod is scheduled on node01" \
  bash -c '
    kubectl get pods -A -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pod in data[\"items\"]:
    ns = pod[\"metadata\"][\"namespace\"]
    if ns.startswith(\"kube-\"):
        continue
    tolerations = pod[\"spec\"].get(\"tolerations\", [])
    for t in tolerations:
        if t.get(\"key\") == \"PERMISSION\" and t.get(\"value\") == \"granted\" and t.get(\"effect\") == \"NoSchedule\":
            node = pod[\"spec\"].get(\"nodeName\", \"\")
            if \"node01\" in node:
                sys.exit(0)
sys.exit(1)
"'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
