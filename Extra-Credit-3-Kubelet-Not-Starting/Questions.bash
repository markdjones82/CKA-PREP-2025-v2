# Question: Kubelet Not Starting
# A coworker was migrating node01 to a new container runtime and updated
# /var/lib/kubelet/kubeadm-flags.env with the new socket path.
# They introduced a typo in the socket path and the node is now NotReady
# with the kubelet failing to start.

# Task:
# 1. Identify why the node is NotReady
# 2. Check the kubelet service status and logs
# 3. Fix the kubelet configuration to use the correct container runtime socket
# 4. Restart the kubelet and verify the node is Ready

# Hints:
# - Check node readiness and kubelet service health
# - Review kubelet logs for container runtime connection issues
# - On kubeadm nodes, the runtime endpoint flag is set in /var/lib/kubelet/kubeadm-flags.env
# - On a working node, run: crictl info | grep Endpoint
# - You can SSH to nodes by name
