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

# Step 4: Calculate correct requests
#
# KEY FORMULA: (allocatable - overhead) / replicas
#
# Overhead = system pods (kube-proxy, coredns, etc.) — typically ~150m CPU / ~250Mi memory
#
# For this lab (1 CPU node):
#   CPU:    (1000m - 150m) / 3 = 850m / 3 ≈ 266m per pod  → use 250m
#   Memory: (1800Mi - 250Mi) / 3 = 1550Mi / 3 ≈ 516Mi per pod
#           BUT the deployment limit is 500Mi, so requests cannot exceed 500Mi
#           → use 300Mi (stays under the 500Mi limit)
#
# For the exam (3 CPU node):
#   CPU:    (3000m - 600m) / 3 = 2400m / 3 = 800m per pod
#   Memory: same formula with the exam node's memory
#
# NOTE: Requests must always be ≤ limits. If your calculated value exceeds
#       the existing limit, use a value just under the limit instead.
# You need to stay UNDER the total, so always round down.

# Step 5: Update WordPress requests (do NOT modify limits)
echo "[*] Patching WordPress deployment with correct requests..."
kubectl -n relative-fawn set resources deployment/wordpress \
  --containers=wordpress \
  --requests=cpu=250m,memory=300Mi

# Alternative: kubectl edit deployment wordpress -n relative-fawn
# Change only the requests section:
#   requests:
#     cpu: "250m"
#     memory: "300Mi"
# Leave limits as-is (300m CPU, 500Mi memory)

# Step 6: Wait for rollout and verify
echo "[*] Waiting for rollout..."
kubectl rollout status deployment wordpress -n relative-fawn --timeout=120s

echo "[*] Verifying all pods are running..."
kubectl get pods -n relative-fawn
# All 3 wordpress pods should be Running

echo "[*] Final resource check..."
kubectl describe node | grep -A10 'Allocated resources'
# Allocated CPU:    ~150m (system) + 3×250m (wordpress) = 900m
# Allocated Memory: ~250Mi (system) + 3×300Mi (wordpress) = 1150Mi

# EXAM TIPS:
# - The formula is key: (allocatable - overhead) / replicas
# - Only REQUESTS matter for scheduling, not limits or actual usage
# - Use kubectl describe node to find allocatable and current allocation
# - Overhead = system pods only (kube-proxy, coredns, etc.)
# - On the exam with 3 CPUs: (3000 - 600) / 3 = 800m per pod
# - On this lab with 1 CPU:  (1000 - 150) / 3 ≈ 266m → use 250m to be safe

echo "[OK] Solution complete!"

