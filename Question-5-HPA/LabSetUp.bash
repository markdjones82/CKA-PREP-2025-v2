#!/bin/bash
set -e

echo "Creating namespace..."
kubectl create namespace autoscale --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying metrics-server (required for HPA)..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "Patching metrics-server to allow insecure TLS (Killercoda environment)..."
kubectl patch deployment metrics-server -n kube-system \
  --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]' || true

echo "Waiting for metrics-server rollout..."
kubectl rollout status deployment metrics-server -n kube-system

echo "Creating Apache deployment..."
kubectl apply -n autoscale -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  namespace: autoscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache
        image: httpd
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
          limits:
            cpu: 200m
EOF

echo "Exposing Apache deployment internally..."
kubectl expose deployment apache-deployment -n autoscale --port=80 --target-port=80

echo "[OK] HPA lab setup complete."
echo "   - Namespace: autoscale"
echo "   - Deployment: apache-deployment"
echo "   - Service: apache-deployment"
echo "You can now create your HPA resource."
