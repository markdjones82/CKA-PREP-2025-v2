#!/bin/bash
# LabSetUp.bash for Question 19 - Resource Allocation v2
# Scenario: WordPress deployment with requests set too low.
# Task: properly divide node resources equally among the 3 replicas.
#
# Killercoda lab node: 1 CPU (1000m), ~1800Mi memory
# System pods consume ~150m CPU / ~250Mi memory as overhead.

set -uo pipefail

echo "[*] Setting up Question 19: Pod Scheduling - Resource Constraints"

# Step 1: Create the namespace
echo "[*] Creating namespace 'relative-fawn'..."
kubectl create namespace relative-fawn --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Deploy WordPress with 3 replicas.
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

