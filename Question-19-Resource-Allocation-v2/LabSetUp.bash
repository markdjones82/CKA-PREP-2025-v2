#!/bin/bash
# LabSetUp.bash for Question 19 - Pod Scheduling / Resource Constraints
# Recreates a CKA exam scenario: WordPress deployment where the 3rd replica
# cannot schedule due to insufficient node CPU.
#
# Killercoda lab node: 1 CPU (1000m), ~1800Mi memory
# Exam node was:       3 CPU (3000m), ~1800Mi memory
# We scale proportionally: exam used 1000m per pod, we use 300m per pod.

set -uo pipefail

echo "[*] Setting up Question 19: Pod Scheduling - Resource Constraints"

# Step 1: Create the namespace
echo "[*] Creating namespace 'relative-fawn'..."
kubectl create namespace relative-fawn --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Deploy a "resource-consumer" workload to simulate other cluster workloads.
# This ensures there isn't enough room for WordPress replica #3.
# On the exam, system/other pods consumed part of the 3 CPU budget.
echo "[*] Deploying background workload (resource-consumer)..."
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitoring-agent
  namespace: relative-fawn
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    metadata:
      labels:
        app: monitoring-agent
    spec:
      containers:
      - name: agent
        image: busybox:latest
        command: ["sh", "-c", "while true; do sleep 30; done"]
        resources:
          requests:
            cpu: "200m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "128Mi"
EOF

echo "[*] Waiting for monitoring-agent to be ready..."
kubectl rollout status deployment monitoring-agent -n relative-fawn --timeout=60s 2>/dev/null || true

# Step 3: Deploy WordPress with 3 replicas.
# Requests are intentionally set LOW (100m/100Mi) — all pods will schedule,
# but the requests don't properly divide the node's resources among the replicas.
echo "[*] Deploying WordPress with 3 replicas..."
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: relative-fawn
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "100Mi"
          limits:
            cpu: "300m"
            memory: "300Mi"
EOF

echo ""
echo "[*] Waiting for WordPress to be ready..."
kubectl rollout status deployment wordpress -n relative-fawn --timeout=120s 2>/dev/null || true

echo ""
echo "[*] Lab setup complete!"
echo ""
echo "Current pod status in namespace 'relative-fawn':"
kubectl get pods -n relative-fawn -o wide
echo ""
echo "All 3 WordPress pods should be Running, but requests are not properly sized."
echo ""
echo "Next steps:"
echo "1. Run: bash Questions.bash"

