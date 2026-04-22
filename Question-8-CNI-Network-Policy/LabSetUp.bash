#!/bin/bash
echo "# Remove the preinstalled Cilium CNI so Calico can be installed cleanly"
kubectl delete daemonset cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete deployment cilium-operator -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete serviceaccount cilium -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete clusterrole cilium --ignore-not-found 2>/dev/null || true
kubectl delete clusterrolebinding cilium --ignore-not-found 2>/dev/null || true
kubectl delete configmap cilium-config -n kube-system --ignore-not-found 2>/dev/null || true
kubectl delete namespace cilium --ignore-not-found 2>/dev/null || true

echo "# Follow the Tigera Calico documentation for the operator and custom resources manifests"
