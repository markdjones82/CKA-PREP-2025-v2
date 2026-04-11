# Solution: Broken API Server

# Step 1: Check that kubectl is not working
kubectl get nodes
# This will fail or hang since the API server is down

# Step 2: Use crictl to find the kube-apiserver container and check logs
sudo crictl ps -a | grep kube-apiserver
# sudo crictl logs <container-id> | tail -20
# Look for errors about invalid service-cluster-ip-range

# Step 3: Inspect the static pod manifest
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
# You will see: --service-cluster-ip-range=999.999.0.0/16

# Note: the question may or may not tell you the correct service CIDR.
# If it does not, you can often infer it from the API server certificate.
# The serving cert usually includes the kubernetes service IP in its SANs.
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A1 'Subject Alternative Name'
# Look for an IP like 10.96.0.1 in the SAN list.
# That is usually the kubernetes default service IP, which implies a CIDR such as 10.96.0.0/12.

# Step 4: Fix the manifest with the correct CIDR
sudo sed -i 's|--service-cluster-ip-range=999.999.0.0/16|--service-cluster-ip-range=10.96.0.0/12|' /etc/kubernetes/manifests/kube-apiserver.yaml

# Step 5: Wait for the kubelet to restart the API server
# The kubelet watches /etc/kubernetes/manifests/ and will automatically restart the pod
sleep 30

# Step 6: Verify the API server is back
kubectl get nodes
kubectl get pods -n kube-system

# Manual verification commands:
# Check the kube-apiserver container is running
sudo crictl ps | grep kube-apiserver

# Confirm the correct CIDR is set
sudo grep service-cluster-ip-range /etc/kubernetes/manifests/kube-apiserver.yaml
