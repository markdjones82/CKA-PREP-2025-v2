#!/bin/bash
set -e

echo "Creating namespace: echo-sound"
kubectl create ns echo-sound || true

echo "Deploying Echo Server in namespace: echo-sound"
cat <<EOF | kubectl -n echo-sound apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo
        image: gcr.io/google_containers/echoserver:1.10
        ports:
        - containerPort: 8080
EOF

echo "✅ Echo server deployment created successfully!"
