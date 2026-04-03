# Solution Link for documentation: https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/#jobs-with-sidecar-containers

# Sidecar notes:
# 1) InitContainer sidecar pattern:
#    - Use an initContainer with restartPolicy: Always.
#    - This is the Kubernetes sidecar pattern for jobs and other workloads.
# 2) Co-located container pattern:
#    - Use a regular container alongside the main app container.
#    - This also works when the sidecar needs to run for the full pod lifetime.
# 3) For log tailing, prefer `tail -F` over `tail -f`.
#    - `-F` follows log files across rotation and re-creation.
#    - `-f` can miss logs after rotation.
# 4) To verify the shared log volume is mounted:
#    - write or confirm a line like `WordPress is running...` in /var/log/wordpress.log
#    - then check the same file from the other container with `kubectl exec`
#    - if both containers can see the same line, the volume is mounted and shared

# Proper solution can use either sidecar style, depending on the task.
# You can edit the deployment to add a sidecar and shared volume and add the volume and mounts.
k edit deployments wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      volumes:
      - name: logs
        emptyDir: {}
        volumeMounts:
        - name: logs
          mountPath: /var/log
      initContainers:
      - name: sidecar
        image: busybox:stable
        command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
        volumeMounts:
        - name: logs
          mountPath: /var/log


# Co-located container version (also valid):
# Use a regular container instead of an initContainer when the sidecar should run with the pod.
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
        volumeMounts:
        - name: logs
          mountPath: /var/log
      - name: sidecar
        image: busybox:stable
        command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
        volumeMounts:
        - name: logs
          mountPath: /var/log
EOF


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
      - name: sidecar
        image: busybox:stable
        restartPolicy: Always
        command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
        volumeMounts:
        - name: logs
          mountPath: /var/log
EOF

kubectl rollout status deployment wordpress
kubectl get pods -l app=wordpress


# Manual verification commands:
# 1) Confirm the Pod and containers are running
kubectl get pods -l app=wordpress -o wide
kubectl describe pod -l app=wordpress

# 2) Confirm the shared log file contains the app output
POD=$(kubectl get pods -l app=wordpress -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD" -c wordpress -- sh -c 'cat /var/log/wordpress.log | tail'

# 3) Confirm the sidecar can see the same file
kubectl exec "$POD" -c sidecar -- sh -c 'cat /var/log/wordpress.log | tail'

# 4) Optional: verify the mounted path inside both containers
kubectl exec "$POD" -c wordpress -- sh -c 'mount | grep /var/log'
kubectl exec "$POD" -c sidecar -- sh -c 'mount | grep /var/log'