#!/bin/bash
# Validation script for Question 5 – HPA (HorizontalPodAutoscaler)
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
echo " Validating Question 5: HPA"
echo "======================================"

# 1. HPA named apache-server exists in autoscale namespace
check "HPA 'apache-server' exists in namespace 'autoscale'" \
  kubectl get hpa apache-server -n autoscale

# 2. HPA targets the deployment apache-deployment
check "HPA targets deployment 'apache-deployment'" \
  bash -c '[[ "$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.scaleTargetRef.name}")" == "apache-deployment" ]]'

check "HPA scaleTargetRef kind is Deployment" \
  bash -c '[[ "$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.scaleTargetRef.kind}")" == "Deployment" ]]'

# 3. CPU target is 50%
check "HPA CPU target is 50% utilization" \
  bash -c '
    UTIL=$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.metrics[0].resource.target.averageUtilization}" 2>/dev/null)
    [[ "$UTIL" == "50" ]]
  '

# 4. Min replicas is 1
check "HPA minReplicas is 1" \
  bash -c '[[ "$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.minReplicas}")" == "1" ]]'

# 5. Max replicas is 4
check "HPA maxReplicas is 4" \
  bash -c '[[ "$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.maxReplicas}")" == "4" ]]'

# 6. Downscale stabilization window is 30 seconds
check "Downscale stabilizationWindowSeconds is 30" \
  bash -c '[[ "$(kubectl get hpa apache-server -n autoscale -o jsonpath="{.spec.behavior.scaleDown.stabilizationWindowSeconds}")" == "30" ]]'

# 7. Target deployment exists
check "Deployment 'apache-deployment' exists in namespace 'autoscale'" \
  kubectl get deployment apache-deployment -n autoscale

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
