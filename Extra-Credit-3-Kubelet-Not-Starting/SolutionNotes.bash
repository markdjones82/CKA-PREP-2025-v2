# Solution: Kubelet Not Starting

# Step 1: Check node status
kubectl get nodes
# The node should show NotReady

# Step 2: SSH to node01 and check kubelet
ssh node01
systemctl status kubelet
# Will show the service is failing or restarting

# Step 3: Check kubelet logs for the exact error
journalctl -u kubelet -n 50
# Look specifically for lines containing the socket path or CRI connection errors:
journalctl -u kubelet -n 100 | grep -i "container runtime\|CRI\|socket\|dial\|no such file"
# You will see an error similar to:
#   dial unix /var/run/containerd/container.sock: connect: no such file or directory
# or:
#   validate service connection: CRI v1 runtime API is not implemented for endpoint
# This tells you exactly which socket path kubelet is trying to connect to

# Step 4: Find what is wrong
# On this kubeadm cluster the runtime endpoint flag is set in kubeadm-flags.env
# Confirm this by checking the kubelet systemd unit:
systemctl cat kubelet
# Look for: EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env

# Then inspect the file:
cat /var/lib/kubelet/kubeadm-flags.env
# You will see a typo: unix:///var/run/containerd/container.sock
# The correct path is: unix:///var/run/containerd/containerd.sock (note the missing 'd')

# To confirm the correct socket path, check a working node:
# crictl info | grep runtimeEndpoint
# Or check /etc/crictl.yaml

# Step 5: Fix the container runtime endpoint
sudo sed -i 's|unix:///var/run/containerd/container.sock|unix:///var/run/containerd/containerd.sock|g' /var/lib/kubelet/kubeadm-flags.env

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
