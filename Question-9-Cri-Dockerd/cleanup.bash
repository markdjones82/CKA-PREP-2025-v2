#!/bin/bash
# Cleanup script for Question 9 - Cri-Dockerd
set -uo pipefail
echo "Cleaning up Question 9: cri-dockerd..."

sudo systemctl disable --now cri-docker.service 2>/dev/null || true
sudo dpkg -r cri-dockerd 2>/dev/null || true
sudo rm -f /etc/sysctl.d/kube.conf
sudo sysctl --system >/dev/null 2>&1 || true

echo "[OK] Question 9 cleanup complete"
