# Taint node01
kubectl taint nodes node01 PERMISSION=granted:NoSchedule

# Pod that tolerates the taint
cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: PERMISSION
    operator: Equal
    value: granted
    effect: NoSchedule
EOF
kubectl apply -f pod.yaml
kubectl get pods

# Negative test (optional) — should stay Pending
cat <<'EOF' > podfailure.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-fail
spec:
  containers:
  - name: nginx
    image: nginx
EOF
kubectl apply -f podfailure.yaml
kubectl describe pod nginx-fail
