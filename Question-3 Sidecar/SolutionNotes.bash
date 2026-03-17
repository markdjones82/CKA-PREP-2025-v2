# Solution Link for docmentation: https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/#jobs-with-sidecar-containers

# Proper Solution uses Sidecar with init container. 
# You can  edit the deployment to add a sidecar and shared volume and add the volume and mounts.
k edit deployments wordpress
  # template:
  #   metadata:
  #     labels:
  #       app: wordpress
  #   spec:
  #     volumes:
  #     - name: logs
  #       emptyDir: {}
  #       volumeMounts:
  #       - name: logs
  #         mountPath: /var/log
  #     initContainers:
  #     - name: init-logs
  #       image: busybox:stable
  #       command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
  #       volumeMounts:
  #       - name: logs
  #         mountPath: /var/log


# Using kubectl patch to add sidecar and shared volume:
# Patch wordpress deployment to add shared volume + sidecar
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      volumes:
      - name: logs
        emptyDir: {}
      containers:
      - name: wordpress
        image: wordpress:php8.2-apache
        ports:
        - containerPort: 80
        command:
        - /bin/sh
        - -c
        - while true; do echo 'WordPress is running...' >> /var/log/wordpress.log; sleep 5; done
        volumeMounts:
        - name: logs
          mountPath: /var/log
      initContainers:
      - name: init-logs
        image: busybox:stable
        restartPolicy: Always
        command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
        volumeMounts:
        - name: logs
          mountPath: /var/log
EOF

kubectl rollout status deployment wordpress
kubectl get pods -l app=wordpress