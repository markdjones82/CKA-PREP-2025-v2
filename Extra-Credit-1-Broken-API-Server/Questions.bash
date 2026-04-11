# Question: Broken API Server
# The kube-apiserver on the controlplane node has stopped working.
# Someone accidentally modified the static pod manifest and changed the
# --service-cluster-ip-range to an invalid CIDR (e.g., 999.999.0.0/16).
# The API server is crashlooping and kubectl commands are failing.

# Task:
# 1. Identify why the kube-apiserver is not starting
# 2. Fix the static pod manifest to restore the correct service CIDR
# 3. Verify the API server comes back up and the cluster is healthy

# Hints:
# - Static pod manifests live in /etc/kubernetes/manifests/
# - Inspect control plane logs and pod manifests when kubectl is unavailable
# - The correct service CIDR may be given in the task or inferred from cluster files
