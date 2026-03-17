# Create PriorityClass just below existing max (e.g., 999)
kubectl create priorityclass high-priority --value=999 --description="high priority"
kubectl get pc

# Patch deployment to use it
kubectl patch deployment busybox-logger -n priority -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
kubectl describe deployment busybox-logger -n priority | grep -i "Priority Class"
