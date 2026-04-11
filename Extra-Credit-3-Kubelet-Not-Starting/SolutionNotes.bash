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
# On kubeadm nodes, the kubelet reads runtime args from /var/lib/kubelet/kubeadm-flags.env
# This is the universal kubeadm location, present on any distro
# Confirm this by checking which files are sourced:
systemctl cat kubelet
# Look for: EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env

# Then inspect the file:
cat /var/lib/kubelet/kubeadm-flags.env
# You will see --container-runtime-endpoint=unix:///run/containerd/bad-socket.sock appended

# Step 5: Fix the container runtime endpoint
# Remove the bad flag by restoring the correct runtime endpoint
# Edit the file and remove the bad --container-runtime-endpoint entry, leaving the rest intact
sudo vi /var/lib/kubelet/kubeadm-flags.env
# Or use sed to remove just the bad flag:
sudo sed -i 's| --container-runtime-endpoint=unix:///run/containerd/bad-socket.sock||g' /var/lib/kubelet/kubeadm-flags.env

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
