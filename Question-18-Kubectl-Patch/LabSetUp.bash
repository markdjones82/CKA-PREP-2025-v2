#!/bin/bash
set -e

# Step 1: Create namespace
kubectl create namespace patch-ns || true

# Step 2: Create deployment with constrained resource limits
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-app
  namespace: patch-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resource-app
  template:
    metadata:
      labels:
        app: resource-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

echo "Lab setup complete."
echo "Deployment 'resource-app' created in namespace 'patch-ns'."
echo "Run Questions.bash to view the task."
