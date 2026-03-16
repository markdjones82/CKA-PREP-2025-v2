# Step 1: create PVC with no storageClass (PV is pre-reset by LabSetUp.bash)
cat <<'EOF' > pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: mariadb
spec:
  accessModes:
  - ReadWriteOnce
  volumeName: mariadb-pv  # bind to specific PV since no storageClass
  resources:
    requests:
      storage: 250Mi
  storageClassName: # Set this to the default storage class name. Some are "standard" some "local-path" etc. Check with "kubectl get storageclass" and look for the one with "(default)" in the name.
EOF
kubectl apply -f pvc.yaml
kubectl get pvc mariadb -n mariadb
kubectl get pv mariadb-pv     # should show Bound to mariadb

# Step 2: ensure deployment uses the PVC
# mariadb-deploy.yaml should mount claimName: mariadb
# (LabSetUp.bash leaves claimName blank for practice)
kubectl apply -f mariadb-deploy.yaml
kubectl get pods -n mariadb
