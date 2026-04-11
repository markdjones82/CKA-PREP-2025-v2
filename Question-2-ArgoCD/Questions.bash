# Question ArgoCD

#Task
# Install Argo CD in a kubernetes cluster using helm while ensuring the CRDs are not installed
# (as they are pre installed)
# 1. Add the official Argo CD Helm repository with the name argocd (https://argoproj.github.io/argo-helm)
# 2. Create a namespace called argocd
# 3. Generate a Helm template from the Argo CD chart version 7.7.3 for the argocd namespace
# 4. Ensure that CRDs are not installed by configuring the chart accordingly
# 5. Save the generated YAML manifest to /root/argo-helm.yaml

# Note: The `--skip-crds` Helm flag does NOT reliably prevent CRD installation for all charts.
# Some charts (like argo-cd) bundle CRDs as regular templates controlled by a chart value. 
# Hint search for the crds value in the argo-cd chart and set it to false to prevent CRD installation.

# Video link - https://youtu.be/e0YGRSjb8CU
