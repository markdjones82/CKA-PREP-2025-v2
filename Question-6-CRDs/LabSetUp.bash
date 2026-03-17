#!/bin/bash
set -e

echo "🔹 Creating namespace: cert-manager"
kubectl create ns cert-manager --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Applying cert-manager CRDs..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.crds.yaml

echo "🔹 Creating minimal cert-manager Deployment..."
cat <<EOF | kubectl apply -n cert-manager -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cert-manager
  template:
    metadata:
      labels:
        app: cert-manager
    spec:
      containers:
      - name: cert-manager
        image: quay.io/jetstack/cert-manager-controller:v1.14.0
        args: ["--v=2"]
EOF

echo "✅ Cert-Manager setup complete."
