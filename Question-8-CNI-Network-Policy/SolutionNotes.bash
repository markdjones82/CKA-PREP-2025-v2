# Follow the Tigera Calico documentation to install the operator and custom resources
# See the Calico docs for the custom-resources.yaml file. https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
# The custom-resources.yaml file is also here:
# https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Get the cluster CIDR from kubeadm (replace with the value from your cluster)
kubectl -n kube-system get cm kubeadm-config -o yaml | grep -n "podSubnet"

# Apply Calico custom resources with the same CIDR as the cluster
# or Download the custom-resources.yaml file and edit the CIDR before applying
wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
vim custom-resources.yaml
# Change the CIDR in the ipPools section to match your cluster CIDR from above command, then apply
kubectl apply -f custom-resources.yaml


kubectl get tigerastatus
kubectl get pods -n calico-system

# Check that all pods are starting, especially CoreDNS
kubectl get pods -A
kubectl get pods -n kube-system | grep coredns
