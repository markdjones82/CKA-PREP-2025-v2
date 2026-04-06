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

# ==============================================================================
# Alternative Approach: Using kubectl patch with a YAML file
# ==============================================================================
#
# This approach is useful when you want to prepare the patch in advance or
# make the changes more explicit.
#
# Step 1: Get the current deployment YAML
kubectl get deployment resource-app -n patch-ns -o yaml > deployment.yaml

# Step 2: Create a patch YAML file with only the fields you want to change
cat > patch.yaml <<'EOF'
spec:
  template:
    spec:
      containers:
      - name: nginx
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# Step 3: Apply the strategic merge patch from the file
kubectl patch deployment resource-app -n patch-ns --patch-file=patch.yaml

# Verify the changes:
kubectl get deployment resource-app -n patch-ns -o jsonpath='{.spec.template.spec.containers[0].resources}' | python3 -m json.tool
