# Step 1: Inspect existing assets (host, secret, backend service/port)
kubectl describe ingress web
kubectl describe secret web-tls

# Step 2: Create Gateway (mirrors Ingress host + TLS)
cat <<'EOF' > gw.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
spec:
  gatewayClassName: nginx-class
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
EOF
kubectl apply -f gw.yaml
kubectl get gateway

# Step 3: Create HTTPRoute (mirrors Ingress rules)
cat <<'EOF' > http.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - "gateway.web.k8s.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
EOF
kubectl apply -f http.yaml

# Step 4: Verify
kubectl describe gateway web-gateway
kubectl describe httproute web-route
