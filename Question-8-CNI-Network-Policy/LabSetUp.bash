#!/bin/bash
# Remove the preinstalled Cilium CNI so Calico can be installed cleanly
kubectl delete daemonset cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete daemonset cilium-envoy -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete serviceaccount cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete clusterrole cilium --ignore-not-found 2>/dev/null || true
kubectl delete clusterrolebinding cilium --ignore-not-found 2>/dev/null || true
kubectl delete configmap cilium-config -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete namespace cilium --ignore-not-found 2>/dev/null || true

# Remove stale Cilium CNI config files from the nodes
sudo rm -f /etc/cni/net.d/*cilium*
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null node01 'sudo rm -f /etc/cni/net.d/*cilium*'

echo "# Remove stale Cilium and Calico VXLAN interfaces from the nodes"
sudo ip link delete vxlan.calico 2>/dev/null || true
sudo ip link delete cilium_vxlan 2>/dev/null || true
sudo ip link delete cilium_host 2>/dev/null || true
sudo ip link delete cilium_net 2>/dev/null || true
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null node01 'sudo ip link delete vxlan.calico 2>/dev/null || true; sudo ip link delete cilium_vxlan 2>/dev/null || true; sudo ip link delete cilium_host 2>/dev/null || true; sudo ip link delete cilium_net 2>/dev/null || true'

kubectl rollout restart deployment coredns -n kube-system

echo "# Follow the Tigera Calico documentation for the operator and custom resources manifests"
