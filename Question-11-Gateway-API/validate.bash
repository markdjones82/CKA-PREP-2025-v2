#!/bin/bash
# Validation script for Question 11 – Gateway API
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
echo " Validating Question 11: Gateway API"
echo "======================================"

# 1. Gateway named web-gateway exists
check "Gateway 'web-gateway' exists" \
  kubectl get gateway web-gateway

# 2. Gateway uses gatewayClassName nginx-class
check "Gateway uses gatewayClassName 'nginx-class'" \
  bash -c '[[ "$(kubectl get gateway web-gateway -o jsonpath="{.spec.gatewayClassName}")" == "nginx-class" ]]'

# 3. Gateway listener uses HTTPS protocol on port 443
check "Gateway listener uses HTTPS on port 443" \
  bash -c '
    PROTO=$(kubectl get gateway web-gateway -o jsonpath="{.spec.listeners[0].protocol}" 2>/dev/null)
    PORT=$(kubectl get gateway web-gateway -o jsonpath="{.spec.listeners[0].port}" 2>/dev/null)
    [[ "$PROTO" == "HTTPS" && "$PORT" == "443" ]]
  '

# 4. Gateway hostname is gateway.web.k8s.local
check "Gateway hostname is 'gateway.web.k8s.local'" \
  bash -c '
    HOST=$(kubectl get gateway web-gateway -o jsonpath="{.spec.listeners[0].hostname}" 2>/dev/null)
    [[ "$HOST" == "gateway.web.k8s.local" ]]
  '

# 5. Gateway references TLS secret (web-tls)
check "Gateway references TLS secret 'web-tls'" \
  bash -c '
    SECRET=$(kubectl get gateway web-gateway -o jsonpath="{.spec.listeners[0].tls.certificateRefs[0].name}" 2>/dev/null)
    [[ "$SECRET" == "web-tls" ]]
  '

# 6. HTTPRoute named web-route exists
check "HTTPRoute 'web-route' exists" \
  kubectl get httproute web-route

# 7. HTTPRoute references parentRef web-gateway
check "HTTPRoute references parentRef 'web-gateway'" \
  bash -c '
    PARENT=$(kubectl get httproute web-route -o jsonpath="{.spec.parentRefs[0].name}" 2>/dev/null)
    [[ "$PARENT" == "web-gateway" ]]
  '

# 8. HTTPRoute hostname is gateway.web.k8s.local
check "HTTPRoute hostname is 'gateway.web.k8s.local'" \
  bash -c '
    HOST=$(kubectl get httproute web-route -o jsonpath="{.spec.hostnames[0]}" 2>/dev/null)
    [[ "$HOST" == "gateway.web.k8s.local" ]]
  '

# 9. HTTPRoute has backend reference
check "HTTPRoute has a backendRef configured" \
  bash -c '
    BACKEND=$(kubectl get httproute web-route -o jsonpath="{.spec.rules[0].backendRefs[0].name}" 2>/dev/null)
    [[ -n "$BACKEND" ]]
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
