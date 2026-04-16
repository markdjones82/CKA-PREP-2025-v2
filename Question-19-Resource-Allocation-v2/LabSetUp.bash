#!/bin/bash
# LabSetUp.bash for Question 19 - Resource Allocation v2

set -uo pipefail

kubectl create namespace relative-fawn --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

cat <<'EOF' | kubectl apply -f - 2>/dev/null
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
            memory: "500Mi"
EOF

echo "Lab setup complete."

