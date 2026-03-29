#!/bin/bash
# Validation script for Question 12 – Ingress
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

echo "======================================"
echo " Validating Question 12: Ingress"
echo "======================================"

# 1. Service echo-service exists in echo-sound namespace
check "Service 'echo-service' exists in namespace 'echo-sound'" \
  kubectl get svc echo-service -n echo-sound

# 2. Service type is NodePort
check "Service type is NodePort" \
  bash -c '[[ "$(kubectl get svc echo-service -n echo-sound -o jsonpath="{.spec.type}")" == "NodePort" ]]'

# 3. Service port is 8080
check "Service port is 8080" \
  bash -c '
    PORT=$(kubectl get svc echo-service -n echo-sound -o jsonpath="{.spec.ports[0].port}" 2>/dev/null)
    [[ "$PORT" == "8080" ]]
  '

# 4. Ingress named echo exists in echo-sound namespace
check "Ingress 'echo' exists in namespace 'echo-sound'" \
  kubectl get ingress echo -n echo-sound

# 5. Ingress host is example.org
check "Ingress host is 'example.org'" \
  bash -c '
    HOST=$(kubectl get ingress echo -n echo-sound -o jsonpath="{.spec.rules[0].host}" 2>/dev/null)
    [[ "$HOST" == "example.org" ]]
  '

# 6. Ingress path is /echo
check "Ingress path is '/echo'" \
  bash -c '
    PATH_VAL=$(kubectl get ingress echo -n echo-sound -o jsonpath="{.spec.rules[0].http.paths[0].path}" 2>/dev/null)
    [[ "$PATH_VAL" == "/echo" ]]
  '

# 7. Ingress backend points to echo-service on port 8080
check "Ingress backend references 'echo-service' port 8080" \
  bash -c '
    SVC=$(kubectl get ingress echo -n echo-sound -o jsonpath="{.spec.rules[0].http.paths[0].backend.service.name}" 2>/dev/null)
    PORT=$(kubectl get ingress echo -n echo-sound -o jsonpath="{.spec.rules[0].http.paths[0].backend.service.port.number}" 2>/dev/null)
    [[ "$SVC" == "echo-service" && "$PORT" == "8080" ]]
  '

# 8. Deployment endpoints are healthy
check "echo-service has endpoints (pods backing the service)" \
  bash -c '
    EP=$(kubectl get endpoints echo-service -n echo-sound -o jsonpath="{.subsets[0].addresses}" 2>/dev/null)
    [[ -n "$EP" && "$EP" != "[]" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
