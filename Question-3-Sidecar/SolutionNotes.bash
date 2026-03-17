# Patch wordpress deployment to add shared volume + sidecar
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  template:
    spec:
      volumes:
      - name: log
        emptyDir: {}
      containers:
      - name: wordpress
        volumeMounts:
        - name: log
          mountPath: /var/log
      - name: sidecar
        image: busybox:stable
        command: ["/bin/sh","-c","tail -f /var/log/wordpress.log"]
        volumeMounts:
        - name: log
          mountPath: /var/log
EOF

kubectl rollout status deployment wordpress
kubectl get pods -l app=wordpress
