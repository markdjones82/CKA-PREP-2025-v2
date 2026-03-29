#!/bin/bash
# Validation script for Question 13 - Network Policy
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
echo " Validating Question 13: Network Policy"
echo "============================================"

# 1. A NetworkPolicy exists in the backend namespace
check "A NetworkPolicy exists in namespace 'backend'" \
  bash -c '
    COUNT=$(kubectl get networkpolicy -n backend --no-headers 2>/dev/null | wc -l)
    [[ "$COUNT" -ge 1 ]]
  '

# 2. NetworkPolicy has ingress rules (not allow-all)
check "NetworkPolicy has specific ingress rules (not blanket allow)" \
  bash -c '
    kubectl get networkpolicy -n backend -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pol in data[\"items\"]:
    ingress = pol[\"spec\"].get(\"ingress\", [])
    if ingress:
        for rule in ingress:
            froms = rule.get(\"from\", [])
            if froms:
                sys.exit(0)
sys.exit(1)
"'

# 3. NetworkPolicy allows traffic from frontend namespace
check "NetworkPolicy allows ingress from frontend namespace" \
  bash -c '
    kubectl get networkpolicy -n backend -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pol in data[\"items\"]:
    ingress = pol[\"spec\"].get(\"ingress\", [])
    for rule in ingress:
        froms = rule.get(\"from\", [])
        for f in froms:
            nssel = f.get(\"namespaceSelector\", {})
            match_labels = nssel.get(\"matchLabels\", {})
            # Check for frontend namespace selector
            for k, v in match_labels.items():
                if \"frontend\" in v or \"frontend\" in k:
                    sys.exit(0)
            # Also check podSelector in combination
            podsel = f.get(\"podSelector\", {})
            if podsel:
                pm = podsel.get(\"matchLabels\", {})
                for k, v in pm.items():
                    if \"frontend\" in v or \"frontend\" in k:
                        sys.exit(0)
sys.exit(1)
"'

# 4. Frontend deployment exists
check "Deployment exists in 'frontend' namespace" \
  bash -c 'kubectl get deployment -n frontend --no-headers 2>/dev/null | wc -l | grep -qv "^0$"'

# 5. Backend deployment exists
check "Deployment exists in 'backend' namespace" \
  bash -c 'kubectl get deployment -n backend --no-headers 2>/dev/null | wc -l | grep -qv "^0$"'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
