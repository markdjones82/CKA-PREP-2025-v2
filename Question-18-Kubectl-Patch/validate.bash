#!/bin/bash
# Validation script for Question 18 - kubectl patch
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
echo " Validating Question 18: kubectl patch"
echo "======================================"

NS="patch-ns"
HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
AUDIT_LOG="${CKA_Q18_AUDIT:-/tmp/cka-q18-audit.log}"

find_history_files() {
  local files=()

  # Prefer the dedicated audit log written by the PROMPT_COMMAND hook (most reliable)
  [[ -f "$AUDIT_LOG" ]] && files+=("$AUDIT_LOG")

  # Fall back to standard history files
  [[ -f "$HISTORY_FILE" ]] && files+=("$HISTORY_FILE")
  [[ -f "/root/.bash_history" ]] && files+=("/root/.bash_history")

  if [[ -n "${SUDO_USER:-}" && -f "/home/${SUDO_USER}/.bash_history" ]]; then
    files+=("/home/${SUDO_USER}/.bash_history")
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    return 1
  fi

  printf '%s\n' "${files[@]}" | sort -u
}

history_contains() {
  local pattern="$1"
  local history_files

  history_files=$(find_history_files) || return 1
  grep -qiE "$pattern" $history_files
}

history_not_contains() {
  local pattern="$1"

  ! history_contains "$pattern"
}

# 1. Namespace patch-ns exists
check "Namespace 'patch-ns' exists" \
  kubectl get namespace "$NS"

# 2. Deployment resource-app exists
check "Deployment 'resource-app' exists in namespace '$NS'" \
  kubectl get deployment resource-app -n "$NS"

# 3. CPU limit updated to 500m
check "Container CPU limit is 500m" \
  bash -c '
    CPU=$(kubectl get deployment resource-app -n '"$NS"' \
      -o jsonpath="{.spec.template.spec.containers[0].resources.limits.cpu}" 2>/dev/null)
    [[ "$CPU" == "500m" ]]
  '

# 4. Memory limit updated to 512Mi
check "Container Memory limit is 512Mi" \
  bash -c '
    MEM=$(kubectl get deployment resource-app -n '"$NS"' \
      -o jsonpath="{.spec.template.spec.containers[0].resources.limits.memory}" 2>/dev/null)
    [[ "$MEM" == "512Mi" ]]
  '

# 5. CPU request unchanged (100m)
check "Container CPU request is still 100m (unchanged)" \
  bash -c '
    CPU_REQ=$(kubectl get deployment resource-app -n '"$NS"' \
      -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null)
    [[ "$CPU_REQ" == "100m" ]]
  '

# 6. Memory request unchanged (128Mi)
check "Container Memory request is still 128Mi (unchanged)" \
  bash -c '
    MEM_REQ=$(kubectl get deployment resource-app -n '"$NS"' \
      -o jsonpath="{.spec.template.spec.containers[0].resources.requests.memory}" 2>/dev/null)
    [[ "$MEM_REQ" == "128Mi" ]]
  '

# 7. Replicas still 2
check "Deployment still has 2 replicas" \
  bash -c '
    REPLICAS=$(kubectl get deployment resource-app -n '"$NS"' \
      -o jsonpath="{.spec.replicas}" 2>/dev/null)
    [[ "$REPLICAS" == "2" ]]
  '

# 8. Pods are running
check "Deployment pods are Running" \
  bash -c '
    kubectl get pods -n '"$NS"' --no-headers 2>/dev/null | grep -q Running
  '

# 9. Verify patch command was used (kubectl or k)
# Note: this checks the persisted history file. The user's interactive shell must
# have already written commands to that file.
check "patch command was used (kubectl or k)" \
  history_contains '(^|[[:space:]])(kubectl|k)[[:space:]].*patch'

# 10. Verify kubectl/k edit was NOT used for resource-app
check "edit command was NOT used for resource-app" \
  history_not_contains '(^|[[:space:]])(kubectl|k)[[:space:]]+edit([[:space:]].*)?resource-app([[:space:]]|$)'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "All checks passed!" || echo "Some checks failed."
exit $FAIL
