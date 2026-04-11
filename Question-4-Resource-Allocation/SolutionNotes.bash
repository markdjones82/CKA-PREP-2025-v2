# Step 0: find the node's allocatable resources
kubectl describe node | grep -A5 "Allocatable:"
# Example output:
#   Allocatable:
#     cpu:     1
#     memory:  1843520Ki
#
# Convert memory from Ki to Mi: divide by 1024
#   1843520Ki / 1024 = 1800Mi
# CPU is already in cores (1 = 1000m)

# Step 1: pause workload
kubectl scale deployment wordpress --replicas 0

# Step 2: edit deployment
kubectl edit deployment wordpress
# There are 3 pods, each with 2 co-located (sidecar) containers = 6 containers total.
# Both containers run simultaneously, so divide node resources by 6:
#   CPU:    1000m / 6 ≈ 166m per container
#   Memory: 1800Mi / 6 = 300Mi per container
#
# Set requests slightly under the even split (scheduling headroom) and limits at/near the max:
# resources:
#   requests:
#     cpu: "150m"
#     memory: "250Mi"
#   limits:
#     cpu: "160m"
#     memory: "300Mi"
# Apply the same values to every container in spec.template.spec.containers[]

# Step 3: resume replicas
kubectl scale deployment wordpress --replicas 3
kubectl rollout status deployment wordpress
kubectl get pods -l app=wordpress
