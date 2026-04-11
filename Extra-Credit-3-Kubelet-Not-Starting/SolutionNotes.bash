# Solution: Kubelet Not Starting

# Step 1: Check node status
kubectl get nodes
# The node should show NotReady

# Step 2: SSH to node01 and check kubelet
ssh node01
systemctl status kubelet
# Will show the service is failing or restarting

# Step 3: Check kubelet logs
journalctl -u kubelet -n 50
# Look for errors about container runtime socket connection refused

# Step 4: Find what is wrong
# Check the kubelet extra args
cat /etc/default/kubelet
# You will see: KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/bad-socket.sock

# Step 5: Fix the container runtime endpoint
echo 'KUBELET_EXTRA_ARGS=' | sudo tee /etc/default/kubelet > /dev/null
# Or set it to the correct socket:
# echo 'KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock' | sudo tee /etc/default/kubelet > /dev/null

# Step 6: Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Step 7: Verify the node comes back
sleep 30
kubectl get nodes
# Node should show Ready

# Manual verification commands:
systemctl is-active kubelet
journalctl -u kubelet -n 10 --no-pager
kubectl get nodes -o wide
