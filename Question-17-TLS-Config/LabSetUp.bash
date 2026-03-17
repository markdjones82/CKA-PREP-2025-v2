#!/bin/bash
set -e

# Step 1: Create namespace
kubectl create namespace nginx-static || true

# Step 2: Create a TLS secret (self-signed)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=ckaquestion.k8s.local"
kubectl -n nginx-static create secret tls nginx-tls --cert=tls.crt --key=tls.key

# Step 3: Create ConfigMap with TLSv1.2 and TLSv1.3 enabled
cat <<EOF | kubectl -n nginx-static apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        ssl_certificate /etc/nginx/tls/tls.crt;
        ssl_certificate_key /etc/nginx/tls/tls.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
          return 200 "Hello TLS\n";
        }
      }
    }
EOF

# Step 4: Deploy nginx using the ConfigMap and TLS secret
cat <<EOF | kubectl -n nginx-static apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: tls
          mountPath: /etc/nginx/tls
      volumes:
      - name: config
        configMap:
          name: nginx-config
      - name: tls
        secret:
          secretName: nginx-tls
EOF

# Step 5: Create a ClusterIP service
kubectl -n nginx-static expose deployment nginx-static --port=443 --target-port=443 --name=nginx-static

echo "nginx TLS lab setup complete."

