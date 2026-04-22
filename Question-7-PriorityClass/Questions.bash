# Question
# You're working in a kubernetes cluster with an existing deployment named busybox-logger running
# in the priority namespace.
# The cluster already has at least one user defined Priority Class

# Tasks:
# 1. Create a new Priority Class named high-priority for user workloads. The value of this class should
# be exactly one less than the highest existing user-defined priority class
# 2. Patch the existing deployment busybox-logger in the priority namespace to use the newly created
# high-priority class

# Video Link - https://youtu.be/CZzxGyF6OHc

#Documentation Reference
# Tip: Navigate the documentation manually to build familiarity with its structure
# (yaml) Reference -> Command line tool (kubectl) -> kubectl reference -> kubectle create -> kubectl create priorityClass
# https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_priorityclass/
# (patch by A-Elfiiky) Tasks -> Manage Kubernetes Objects -> Update API Objects in place using Kubectl patch
# https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/