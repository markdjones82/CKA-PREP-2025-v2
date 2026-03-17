# Install Calico (supports NetworkPolicy)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
kubectl get all -n tigera-operator
