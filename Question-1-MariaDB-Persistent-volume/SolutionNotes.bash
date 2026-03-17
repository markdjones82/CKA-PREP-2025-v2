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
  resources:
    requests:
      storage: 250Mi
EOF
kubectl apply -f pvc.yaml
kubectl get pvc mariadb -n mariadb
kubectl get pv mariadb-pv     # should show Bound to mariadb

# Step 2: ensure deployment uses the PVC
# mariadb-deploy.yaml should mount claimName: mariadb
# (LabSetUp.bash leaves claimName blank for practice)
kubectl apply -f mariadb-deploy.yaml
kubectl get pods -n mariadb
