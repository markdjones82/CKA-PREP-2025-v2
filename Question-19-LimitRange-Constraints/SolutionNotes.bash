# Solution Notes for Question 19: Properly Size WordPress Resource Requests

# Step 1: Check the node's allocatable resources
echo "[*] Checking node allocatable..."
kubectl describe node | grep -A6 'Allocatable'
# Allocatable:
#   cpu:                1           (= 1000m)
#   memory:             1846528Ki   (≈ 1800Mi)

# Step 2: Check currently allocated resources
echo "[*] Checking allocated resources..."
kubectl describe node | grep -A10 'Allocated resources'
# You'll see the sum of all pod requests vs allocatable

# Step 3: List all pod requests in the namespace
echo "[*] Listing pod requests..."
kubectl get pods -n relative-fawn -o custom-columns="NAME:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory"
# wordpress pods: 100m CPU, 100Mi memory each (too low!)
# monitoring-agent: 200m CPU, 128Mi memory

# Step 4: Calculate correct requests
#
# KEY FORMULA: (allocatable - overhead) / replicas
#
# For this lab (1 CPU node):
#   CPU:    (1000m - ~200m overhead) / 3 = 800m / 3 ≈ 266m per pod
#   Memory: (1800Mi - ~250Mi overhead) / 3 = 1550Mi / 3 ≈ 516Mi per pod
#
# For the exam (3 CPU node):
#   CPU:    (3000m - 600m overhead) / 3 = 2400m / 3 = 800m per pod
#   Memory: same formula with the exam node's memory
#
# "Overhead" includes system pods (kube-proxy, coredns, etc.) + monitoring-agent
# You need to stay UNDER the total, so round down.

# Step 5: Update WordPress requests (do NOT modify limits)
echo "[*] Patching WordPress deployment with correct requests..."
kubectl -n relative-fawn set resources deployment/wordpress \
  --containers=wordpress \
  --requests=cpu=250m,memory=500Mi

# Alternative: kubectl edit deployment wordpress -n relative-fawn
# Change only the requests section:
#   requests:
#     cpu: "250m"
#     memory: "500Mi"
# Leave limits as-is (300m CPU, 300Mi memory)

# Step 6: Wait for rollout and verify
echo "[*] Waiting for rollout..."
kubectl rollout status deployment wordpress -n relative-fawn --timeout=120s

echo "[*] Verifying all pods are running..."
kubectl get pods -n relative-fawn
# All 3 wordpress pods + monitoring-agent should be Running

echo "[*] Final resource check..."
kubectl describe node | grep -A10 'Allocated resources'
# Allocated CPU:    200m (agent) + 3×250m (wordpress) = 950m
# Allocated Memory: 128Mi (agent) + 3×500Mi (wordpress) = 1628Mi

# EXAM TIPS:
# - The formula is key: (allocatable - overhead) / replicas
# - Only REQUESTS matter for scheduling, not limits or actual usage
# - Use kubectl describe node to find allocatable and current allocation
# - Always account for system pods and other workloads (the "overhead")
# - On the exam with 3 CPUs: (3000 - 600) / 3 = 800m per pod
# - On this lab with 1 CPU:  (1000 - 200) / 3 ≈ 266m → use 250m to be safe

echo "[OK] Solution complete!"

