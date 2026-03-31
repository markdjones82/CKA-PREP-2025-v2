# Compare provided policies and pick the least permissive that matches requirements
cat /root/network-policies/network-policy-1.yaml   # allows all ingress (too open)
cat /root/network-policies/network-policy-2.yaml   # extra IP allowed (too open)
cat /root/network-policies/network-policy-3.yaml   # only frontend namespace/pods allowed
kubectl get pods -n frontend --show-labels         # confirm app=frontend label
kubectl apply -f /root/network-policies/network-policy-3.yaml

# Validate connectivity from frontend to backend
# Replace the pod name below with the actual frontend pod name from: kubectl get pods -n frontend
kubectl exec -n frontend frontend-deployment-5cfd995957-vdhfw -- curl -v --connect-timeout 5 backend-service.backend.svc.cluster.local:80
