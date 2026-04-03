# Solution: Pod Resource Limits and Reservations

NS="resource-lab"

# Step 1: Set resource requests and limits on the deployment
kubectl set resources deployment web-app -n $NS \
  --requests=cpu=200m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi

# Alternatively, edit the deployment directly:
# kubectl edit deployment web-app -n $NS
# Add under containers[0]:
#   resources:
#     requests:
#       cpu: "200m"
#       memory: "256Mi"
#     limits:
#       cpu: "500m"
#       memory: "512Mi"

# Step 2: Create a LimitRange
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: $NS
spec:
  limits:
  - default:
      cpu: "300m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "1"
      memory: "1Gi"
    type: Container
EOF

# Step 3: Create a ResourceQuota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota
  namespace: $NS
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
EOF

# Step 4: Verify the rollout
kubectl rollout status deployment web-app -n $NS
kubectl get pods -n $NS

# Manual verification commands:
# Check resource requests/limits on the pods
kubectl describe deployment web-app -n $NS | grep -A6 "Limits\|Requests"

# Check the LimitRange
kubectl describe limitrange default-limits -n $NS

# Check the ResourceQuota
kubectl describe resourcequota resource-quota -n $NS

# Confirm pod resources from a running pod
POD=$(kubectl get pods -n $NS -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl get pod "$POD" -n $NS -o jsonpath='{.spec.containers[0].resources}' | python3 -m json.tool
