#!/bin/bash
set -e

echo "🔹 Creating namespaces..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Deploying backend app..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
EOF

echo "🔹 Exposing backend as ClusterIP service..."
kubectl expose deployment backend-deployment -n backend --port=80 --target-port=80 --name=backend-service

echo "🔹 Deploying frontend app..."
kubectl apply -n frontend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "🔹 Creating NetworkPolicy files..."
mkdir -p /root/network-policies
cd /root/network-policies

cat <<EOF > network-policy-1.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-x
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
EOF

cat <<EOF > network-policy-2.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-y
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - ipBlock:
        cidr: 172.16.0.0/16
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

cat <<EOF > network-policy-3.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-z
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

cd /
echo "✅ Lab setup complete. Three network policy files created in /root/network-policies."
