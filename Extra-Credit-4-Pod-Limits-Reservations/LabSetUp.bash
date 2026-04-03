#!/bin/bash
set -e

echo "Setting up Extra Credit 4: Pod Resource Limits and Reservations..."

NS="resource-lab"

# Create namespace
kubectl create ns "$NS" --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment with no resource requests or limits
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: $NS
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

echo "Waiting for deployment to be available..."
kubectl wait --for=condition=Available deployment/web-app -n "$NS" --timeout=60s || true

echo "[OK] Lab setup complete!"
echo "   - Namespace: $NS"
echo "   - Deployment: web-app (3 replicas, no resource requests/limits)"
echo "   - Task: Add requests, limits, LimitRange, and ResourceQuota"
