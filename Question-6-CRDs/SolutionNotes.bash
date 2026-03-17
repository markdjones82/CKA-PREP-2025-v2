# List cert-manager CRDs and save
kubectl get crd | grep cert-manager | tee /root/resources.yaml

# Save spec subject explain output
kubectl explain certificate.spec.subject | tee /root/subject.yaml
