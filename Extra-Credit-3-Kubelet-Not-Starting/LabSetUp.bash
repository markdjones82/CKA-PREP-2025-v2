#!/bin/bash
set -e

echo "Setting up Extra Credit 3: Kubelet Not Starting... This lab takes about 2 minutes to setup."

BAD_NODE="node01"

# Write a script to node01 and execute it there to avoid SSH quoting issues
# The coworker was trying to migrate the container runtime and introduced a typo
# in the runtime endpoint flag inside kubeadm-flags.env
cat > /tmp/break-kubelet.sh << 'EOF'
#!/bin/bash
cp /var/lib/kubelet/kubeadm-flags.env /root/kubeadm-flags.env.bak
sed -i 's|unix:///var/run/containerd/containerd.sock|unix:///var/run/containerd/container.sock|g' /var/lib/kubelet/kubeadm-flags.env
systemctl daemon-reload
systemctl restart kubelet || true
EOF

scp /tmp/break-kubelet.sh ${BAD_NODE}:/tmp/break-kubelet.sh
ssh "$BAD_NODE" "sudo bash /tmp/break-kubelet.sh"

echo "Waiting for node01 to show NotReady..."
while true; do
  STATUS=$(kubectl get node node01 --no-headers 2>/dev/null | awk '{print $2}')
  if [[ "$STATUS" == "NotReady" ]]; then
    echo "node01 is NotReady."
    break
  fi
  sleep 2
done

echo "[OK] Lab setup complete!"
