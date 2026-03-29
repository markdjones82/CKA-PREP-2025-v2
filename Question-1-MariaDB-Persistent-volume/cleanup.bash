#!/bin/bash
# Cleanup script for Question 1 - MariaDB Persistent Volume
set -uo pipefail
echo "Cleaning up Question 1: MariaDB Persistent Volume..."

kubectl delete deployment mariadb -n mariadb --ignore-not-found
kubectl delete pvc mariadb -n mariadb --ignore-not-found
kubectl delete pv mariadb-pv --ignore-not-found
kubectl delete namespace mariadb --ignore-not-found
rm -f ~/mariadb-deploy.yaml ~/pvc.yaml

echo "[OK] Question 1 cleanup complete"
