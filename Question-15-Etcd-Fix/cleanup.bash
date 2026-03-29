#!/bin/bash
# Cleanup script for Question 15 - Etcd Fix
set -uo pipefail
echo "Cleaning up Question 15: Etcd Fix..."

# Re-introduce the broken etcd port to reset the lab for re-practice
# (only do this if you want to re-run the lab from scratch)
echo "NOTE: This question modifies /etc/kubernetes/manifests/kube-apiserver.yaml"
echo "To reset for re-practice, re-run: scripts/run-question.sh 15"
echo "To leave the cluster healthy, no action is taken."

echo "[OK] Question 15 cleanup complete (no destructive action taken)"
