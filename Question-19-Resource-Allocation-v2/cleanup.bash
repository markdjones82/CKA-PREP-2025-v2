#!/bin/bash
# Cleanup script for Question 19 - WordPress Pod Scheduling

set -uo pipefail

echo "[*] Cleaning up Question 19: WordPress Scheduling..."

# Delete the namespace (this removes all resources inside it)
kubectl delete namespace relative-fawn --ignore-not-found
echo "[OK] Namespace 'relative-fawn' deleted (includes wordpress + monitoring-agent)"

echo "[OK] Question 19 cleanup complete"

