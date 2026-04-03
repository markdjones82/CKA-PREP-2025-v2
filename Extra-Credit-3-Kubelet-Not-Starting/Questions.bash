# Question: Kubelet Not Starting
# A worker node in the cluster is showing NotReady status.
# The kubelet service has stopped and someone has modified the kubelet configuration
# to point to the wrong container runtime socket.

# Task:
# 1. Identify why the node is NotReady
# 2. Check the kubelet service status and logs
# 3. Fix the kubelet configuration to use the correct container runtime socket
# 4. Restart the kubelet and verify the node is Ready

# Hints:
# - Check node status: kubectl get nodes
# - Check kubelet status: systemctl status kubelet
# - Check kubelet logs: journalctl -u kubelet -n 50
# - Kubelet config can be in /var/lib/kubelet/config.yaml or /etc/default/kubelet
# - The correct containerd socket is: unix:///run/containerd/containerd.sock
