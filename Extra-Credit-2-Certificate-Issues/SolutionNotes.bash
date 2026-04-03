# Solution: Certificate Issues

# Step 1: Check that kubectl is failing
kubectl get nodes
# Should fail with TLS handshake error or certificate expired

# Step 2: Inspect the API server certificate
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout
# Look for:
#   - Subject: CN = bad-apiserver  (wrong CN)
#   - Not After: already expired

# Step 3: Check which certificates kubeadm manages
sudo kubeadm certs check-expiration

# Step 4: Renew the API server certificate
sudo kubeadm certs renew apiserver

# Step 5: Restart the kube-apiserver by moving the manifest out and back
# The kubelet watches /etc/kubernetes/manifests/ and restarts static pods
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
sleep 5
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
sleep 30

# Step 6: Verify the cluster is working
kubectl get nodes
kubectl get pods -n kube-system

# Manual verification commands:
# Confirm the new cert has a valid expiry and correct CN
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -E "Subject:|Not After"

# Confirm API server is using the new cert
sudo crictl ps | grep kube-apiserver
