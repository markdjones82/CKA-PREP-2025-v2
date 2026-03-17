#!/bin/bash
set -e

echo "🔹 Creating namespace..."
kubectl create ns mariadb --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating PersistentVolume..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
  labels:
    app: mariadb
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard  # Use default storage class so PVC without storageClassName binds
  hostPath:
    path: /mnt/data/mariadb
EOF

echo "🔹 Creating initial PVC..."
kubectl apply -f - <<EOF
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

echo "🔹 Creating initial MariaDB Deployment..."
cat <<EOF > ~/mariadb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.6
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: mariadb
EOF

kubectl apply -f ~/mariadb-deploy.yaml

echo "🔹 Waiting for MariaDB pod to start..."
kubectl wait --for=condition=Available deployment/mariadb -n mariadb --timeout=60s || true

echo "🔹 Simulating accidental deletion of Deployment and PVC..."
kubectl delete deployment mariadb -n mariadb --ignore-not-found
kubectl delete pvc mariadb -n mariadb --ignore-not-found

echo "🔹 Resetting PV for reuse (clearing any stale claimRef)..."
claim_ref=$(kubectl get pv mariadb-pv -o jsonpath='{.spec.claimRef.name}' 2>/dev/null || true)
if [ -n "$claim_ref" ]; then
  kubectl patch pv mariadb-pv --type=json -p '[{"op":"remove","path":"/spec/claimRef"}]'
fi

# Refresh the deployment manifest for practice: claimName intentionally left blank
cat <<'EOF' > ~/mariadb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.6
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: ""
EOF

echo "✅ Lab setup complete!"
echo "   - PV retained and ready for reuse"
echo "   - Namespace: mariadb"
echo "   - Task: recreate PVC and deployment reusing existing PV (fill claimName in ~/mariadb-deploy.yaml)"
