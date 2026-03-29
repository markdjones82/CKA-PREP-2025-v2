#!/bin/bash
# Validation script for Question 17 – TLS Config
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
echo " Validating Question 17: TLS Config"
echo "======================================"

NS="nginx-static"

# 1. ConfigMap nginx-config exists
check "ConfigMap 'nginx-config' exists in namespace '$NS'" \
  kubectl get configmap nginx-config -n "$NS"

# 2. ConfigMap does NOT contain TLSv1.2
check "ConfigMap does NOT reference TLSv1.2" \
  bash -c '
    CM_DATA=$(kubectl get configmap nginx-config -n '"$NS"' -o json 2>/dev/null)
    ! echo "$CM_DATA" | grep -q "TLSv1.2"
  '

# 3. ConfigMap contains TLSv1.3
check "ConfigMap references TLSv1.3" \
  bash -c '
    CM_DATA=$(kubectl get configmap nginx-config -n '"$NS"' -o json 2>/dev/null)
    echo "$CM_DATA" | grep -q "TLSv1.3"
  '

# 4. /etc/hosts has entry for ckaquestion.k8s.local
check "/etc/hosts contains entry for 'ckaquestion.k8s.local'" \
  bash -c 'grep -q "ckaquestion.k8s.local" /etc/hosts'

# 5. /etc/hosts IP matches service IP
check "/etc/hosts IP matches nginx-service ClusterIP" \
  bash -c '
    SVC_IP=$(kubectl get svc nginx-service -n '"$NS"' -o jsonpath="{.spec.clusterIP}" 2>/dev/null)
    grep "ckaquestion.k8s.local" /etc/hosts | grep -q "$SVC_IP"
  '

# 6. Deployment is running
check "nginx-static deployment is running" \
  bash -c '
    kubectl get deployment -n '"$NS"' --no-headers 2>/dev/null | grep -q "nginx"
  '

# 7. Pods are running
check "nginx-static pods are Running" \
  bash -c '
    kubectl get pods -n '"$NS"' --no-headers 2>/dev/null | grep -q Running
  '

# 8. TLS 1.2 connection fails (if curl available and service reachable)
check "TLS 1.2 connection is rejected" \
  bash -c '
    SVC_IP=$(kubectl get svc nginx-service -n '"$NS"' -o jsonpath="{.spec.clusterIP}" 2>/dev/null)
    if [[ -z "$SVC_IP" ]]; then exit 1; fi
    # curl with --tls-max 1.2 should fail (exit code != 0 or HTTP error)
    ! curl -sk --max-time 5 --tls-max 1.2 "https://$SVC_IP" >/dev/null 2>&1
  '

# 9. TLS 1.3 connection succeeds
check "TLS 1.3 connection succeeds" \
  bash -c '
    SVC_IP=$(kubectl get svc nginx-service -n '"$NS"' -o jsonpath="{.spec.clusterIP}" 2>/dev/null)
    if [[ -z "$SVC_IP" ]]; then exit 1; fi
    curl -sk --max-time 5 --tlsv1.3 "https://$SVC_IP" >/dev/null 2>&1
  '

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
