# Question: Kubelet Not Starting
# A node is showing NotReady status.
# The kubelet service has stopped and someone has modified the kubelet configuration
# to point to the wrong container runtime socket.

# Task:
# 1. Identify why the node is NotReady
# 2. Check the kubelet service status and logs
# 3. Fix the kubelet configuration to use the correct container runtime socket
# 4. Restart the kubelet and verify the node is Ready

# Hints:
# - Check node readiness and kubelet service health
# - Review kubelet logs for container runtime connection issues
# - Inspect the kubelet systemd drop-in to find which config files are sourced
# - On kubeadm nodes, runtime args are set in /var/lib/kubelet/kubeadm-flags.env
# - You can SSH to nodes by name
