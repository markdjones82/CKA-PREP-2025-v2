# Solution: kubectl patch to update resource limits
#
# Use a strategic merge patch to update only the resource limits of the nginx container.
# Strategic merge patch is smart enough to match the container by name, so it will
# only change the fields you specify and leave everything else (requests, replicas, etc.) intact.

kubectl patch deployment resource-app -n patch-ns \
  --type='strategic' \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"limits":{"cpu":"500m","memory":"512Mi"}}}]}}}}'

# Alternatively, using a JSON merge patch (--type=merge) also works but note that
# merge patch replaces the entire "limits" object, so you must include all limit fields:
#
# kubectl patch deployment resource-app -n patch-ns \
#   --type='merge' \
#   -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"limits":{"cpu":"500m","memory":"512Mi"}}}]}}}}'

# Verify the change was applied:
kubectl get deployment resource-app -n patch-ns \
  -o jsonpath='{.spec.template.spec.containers[0].resources}' | python3 -m json.tool

# Or check with describe:
kubectl describe deployment resource-app -n patch-ns | grep -A 5 "Limits:"
