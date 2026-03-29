#!/bin/bash
# Validation script for Question 6 - CRDs (cert-manager)
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
echo " Validating Question 6: CRDs"
echo "======================================"

# 1. /root/resources.yaml exists and is not empty
check "File /root/resources.yaml exists" \
  test -f /root/resources.yaml

check "File /root/resources.yaml is not empty" \
  test -s /root/resources.yaml

# 2. /root/resources.yaml contains cert-manager CRDs
check "/root/resources.yaml lists cert-manager CRDs" \
  bash -c 'grep -qi "cert-manager" /root/resources.yaml'

# 3. /root/subject.yaml exists and is not empty
check "File /root/subject.yaml exists" \
  test -f /root/subject.yaml

check "File /root/subject.yaml is not empty" \
  test -s /root/subject.yaml

# 4. /root/subject.yaml contains subject-related documentation
check "/root/subject.yaml contains subject specification info" \
  bash -c 'grep -qi "subject\|organization\|country\|province\|locality" /root/subject.yaml'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
