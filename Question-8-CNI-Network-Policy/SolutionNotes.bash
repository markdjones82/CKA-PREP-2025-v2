# Remove the preinstalled Cilium CNI first
kubectl delete daemonset cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete deployment cilium-operator -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete serviceaccount cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete clusterrole cilium --ignore-not-found 2>/dev/null || true
kubectl delete clusterrolebinding cilium --ignore-not-found 2>/dev/null || true
kubectl delete configmap cilium-config -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete namespace cilium --ignore-not-found 2>/dev/null || true

# Follow the Tigera Calico documentation to install the operator and custom resources
# See the Calico docs for the custom-resources.yaml file.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Get the cluster CIDR from kubeadm (replace with the value from your cluster)
kubectl -n kube-system get cm kubeadm-config -o yaml | grep -n "podSubnet"

# Apply Calico custom resources with the same CIDR as the cluster
cat <<EOF | kubectl apply -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
      - blockSize: 26
        cidr: <cluster-cidr>
        encapsulation: VXLANCrossSubnet
        natOutgoing: Enabled
        nodeSelector: all()
EOF

kubectl get tigerastatus
kubectl get pods -n calico-system
