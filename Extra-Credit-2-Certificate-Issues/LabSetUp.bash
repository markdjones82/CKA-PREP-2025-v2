#!/bin/bash
set -Eeuo pipefail

trap 'echo "[ERROR] Lab setup failed at line $LINENO: $BASH_COMMAND" >&2' ERR

echo "Setting up Extra Credit 2: Certificate Issues..."

# Backup original certs
sudo cp /etc/kubernetes/pki/apiserver.crt /root/apiserver.crt.bak
sudo cp /etc/kubernetes/pki/apiserver.key /root/apiserver.key.bak

# Generate an actually expired API server cert signed by the cluster CA.
# This keeps the setup realistic while still breaking kubectl due to expiry.
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

NODE_IP="$(hostname -I | awk '{print $1}')"

cat > "$WORKDIR/openssl.cnf" <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = /etc/kubernetes/pki
database = $WORKDIR/index.txt
new_certs_dir = $WORKDIR/newcerts
certificate = /etc/kubernetes/pki/ca.crt
private_key = /etc/kubernetes/pki/ca.key
serial = $WORKDIR/serial
default_md = sha256
policy = policy_any
copy_extensions = copy
unique_subject = no

[ policy_any ]
commonName = supplied

[ req ]
prompt = no
distinguished_name = dn
req_extensions = v3_apiserver

[ dn ]
CN = kubernetes

[ v3_apiserver ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = ${NODE_IP}
EOF

mkdir -p "$WORKDIR/newcerts"
: > "$WORKDIR/index.txt"
echo 1000 > "$WORKDIR/serial"

openssl req -new -nodes -newkey rsa:2048 \
  -keyout "$WORKDIR/apiserver.key" \
  -out "$WORKDIR/apiserver.csr" \
  -config "$WORKDIR/openssl.cnf" \
  >/dev/null 2>&1

PAST_START="$(date -u -d '2 days ago' '+%Y%m%d%H%M%SZ')"
PAST_END="$(date -u -d '1 day ago' '+%Y%m%d%H%M%SZ')"

openssl ca -batch \
  -config "$WORKDIR/openssl.cnf" \
  -in "$WORKDIR/apiserver.csr" \
  -out /etc/kubernetes/pki/apiserver.crt \
  -startdate "$PAST_START" \
  -enddate "$PAST_END" \
  -extensions v3_apiserver \
  >/dev/null 2>&1

sudo cp "$WORKDIR/apiserver.key" /etc/kubernetes/pki/apiserver.key

echo "Waiting for kubelet to detect certificate change..."
sleep 10

# Force the API server pod to restart by touching the manifest
sudo touch /etc/kubernetes/manifests/kube-apiserver.yaml
sleep 5

echo "[OK] Lab setup complete!"
echo "   - The API server certificate has been replaced with an expired one"
echo "   - kubectl commands will fail with TLS errors"
echo "   - Check cert expiry with a certificate inspection command"
echo "   - Use kubeadm to regenerate the API server certificate"
