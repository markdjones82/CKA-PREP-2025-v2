# Compare provided policies and pick the least permissive that matches requirements
cat /root/network-policies/network-policy-1.yaml   # allows all ingress (too open)
cat /root/network-policies/network-policy-2.yaml   # extra IP allowed (too open)
cat /root/network-policies/network-policy-3.yaml   # only frontend namespace/pods allowed
kubectl get pods -n frontend --show-labels         # confirm app=frontend label
kubectl apply -f /root/network-policies/network-policy-3.yaml
