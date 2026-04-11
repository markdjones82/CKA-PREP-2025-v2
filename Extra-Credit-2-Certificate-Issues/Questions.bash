# Question: Expired / Invalid Certificates
# The cluster was working fine yesterday, but today kubectl commands are returning
# TLS handshake errors. Someone rotated the API server serving certificate but
# used a wrong CN (Common Name) and the certificate has already expired.

# Task:
# 1. Identify which certificate is causing the issue
# 2. Regenerate the expired/invalid API server certificates using kubeadm
# 3. Restart the affected components
# 4. Verify the cluster is healthy and kubectl works again

# Hints:
# - Check certificate files under /etc/kubernetes/pki/
# - Inspect certificate details and expiry before changing anything
# - kubeadm can regenerate the required certs