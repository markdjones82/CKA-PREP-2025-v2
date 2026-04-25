# Solution Link for documentation: https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/#jobs-with-sidecar-containers

# Sidecar notes:
# 1) Exam-preferred solution: Co-located container pattern (n + 1 containers).
#    - Add a regular container alongside the main app container in the same pod.
#    - This is the approach the CKA exam expects for Deployments.
#    - Use `tail -F` (capital F) instead of `tail -f` (lowercase):
#      - `-F` follows log files across rotation and re-creation.
#      - `-f` can miss logs after rotation.
# 2) To verify the shared log volume is mounted:
#    - write or confirm a line like `WordPress is running...` in /var/log/wordpress.log
#    - then check the same file from the other container with `kubectl exec`
#    - if both containers can see the same line, the volume is mounted and shared

# ─────────────────────────────────────────────────────────────────────────────
# EXAM-PREFERRED SOLUTION: Co-located sidecar container (n + 1 pattern)
# ─────────────────────────────────────────────────────────────────────────────
# The exam expects a regular co-located container (not an initContainer) added
# to the Deployment.  Use kubectl edit or apply a full manifest with -f.

# Option A – kubectl edit (imperative, fastest in exam conditions):
k edit deployments wordpress
# The existing wordpress container already runs the log-writing command in this lab,
# so you only need to add three things:
#   1. A shared volume under spec.template.spec
#   2. A volumeMount for the existing wordpress container
#   3. The new co-located sidecar container
#
#   spec:
#     volumes:
#     - name: logs
#       emptyDir: {}
#     containers:
#     - name: wordpress          # existing container – add volumeMounts here
#       ...
#       volumeMounts:
#       - name: logs
#         mountPath: /var/log
#     - name: sidecar            # new co-located container
#       image: busybox:stable
#       command: ['sh', '-c', 'tail -F /var/log/wordpress.log']
#       volumeMounts:
#       - name: logs
#         mountPath: /var/log

# Option B – apply a full manifest with kubectl apply -f (declarative):
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
      - name: sidecar
        image: busybox:stable
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


# ─────────────────────────────────────────────────────────────────────────────
# FOR REFERENCE / LEARNING ONLY: InitContainer sidecar pattern
# ─────────────────────────────────────────────────────────────────────────────
# Kubernetes 1.29+ introduced native sidecar support via initContainers with
# restartPolicy: Always.  This is useful for Jobs (where regular containers
# would keep the Job alive), but the CKA exam for Deployment tasks expects the
# co-located container approach above.  This section is provided for learning.
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