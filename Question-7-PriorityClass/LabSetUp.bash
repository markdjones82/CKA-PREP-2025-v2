#!/bin/bash
set -e

echo "Creating namespace: priority"
kubectl create namespace priority --dry-run=client -o yaml | kubectl apply -f -

echo "Creating user-defined PriorityClass: user-critical"
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: user-critical
value: 1000
globalDefault: false
description: "Highest user-defined priority class"
EOF

echo "Creating deployment: busybox-logger in 'priority' namespace"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "while true; do echo 'logging...'; sleep 5; done"]
EOF

echo "✅ Lab setup complete!"
