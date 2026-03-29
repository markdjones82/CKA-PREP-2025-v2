#!/bin/bash
# Validation script for Question 14 - Storage Class
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
echo " Validating Question 14: Storage Class"
echo "============================================"

# 1. StorageClass local-storage exists
check "StorageClass 'local-storage' exists" \
  kubectl get storageclass local-storage

# 2. Provisioner is rancher.io/local-path
check "StorageClass provisioner is 'rancher.io/local-path'" \
  bash -c '[[ "$(kubectl get storageclass local-storage -o jsonpath="{.provisioner}")" == "rancher.io/local-path" ]]'

# 3. VolumeBindingMode is WaitForFirstConsumer
check "VolumeBindingMode is 'WaitForFirstConsumer'" \
  bash -c '[[ "$(kubectl get storageclass local-storage -o jsonpath="{.volumeBindingMode}")" == "WaitForFirstConsumer" ]]'

# 4. local-storage is the default StorageClass
check "StorageClass 'local-storage' is the default" \
  bash -c '
    IS_DEFAULT=$(kubectl get storageclass local-storage -o jsonpath="{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}" 2>/dev/null)
    [[ "$IS_DEFAULT" == "true" ]]
  '

# 5. Only one default StorageClass exists (local-storage)
check "Only one default StorageClass exists" \
  bash -c '
    DEFAULT_COUNT=$(kubectl get storageclass -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
count = 0
for sc in data[\"items\"]:
    annotations = sc[\"metadata\"].get(\"annotations\", {})
    if annotations.get(\"storageclass.kubernetes.io/is-default-class\") == \"true\":
        count += 1
print(count)
")
    [[ "$DEFAULT_COUNT" == "1" ]]
  '

# 6. No other StorageClass is marked as default
check "No other StorageClass is marked default" \
  bash -c '
    kubectl get storageclass -o json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for sc in data[\"items\"]:
    name = sc[\"metadata\"][\"name\"]
    if name == \"local-storage\":
        continue
    annotations = sc[\"metadata\"].get(\"annotations\", {})
    if annotations.get(\"storageclass.kubernetes.io/is-default-class\") == \"true\":
        sys.exit(1)
sys.exit(0)
"'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
