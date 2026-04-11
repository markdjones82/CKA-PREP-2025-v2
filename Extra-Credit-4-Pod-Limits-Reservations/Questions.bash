# Question: Pod Resource Limits and Reservations
# You have a deployment called "web-app" running in the "resource-lab" namespace with 3 replicas.
# The pods are running without any resource requests or limits defined.
# The node has 2 CPU cores and 4Gi of memory available.

# Task:
# 1. Set resource requests (reservations) on each pod: 200m CPU and 256Mi memory
# 2. Set resource limits on each pod: 500m CPU and 512Mi memory
# 3. Create a LimitRange in the namespace that enforces:
#    - Default request: 100m CPU, 128Mi memory
#    - Default limit: 300m CPU, 256Mi memory
#    - Max limit: 1 CPU, 1Gi memory
# 4. Create a ResourceQuota for the namespace:
#    - Max total requests: 2 CPU, 4Gi memory
#    - Max total limits: 4 CPU, 8Gi memory
# 5. Verify all pods are running with the correct resource settings

# Hints:
# - Update the deployment resource settings for the container
# - Create namespace policies for defaults and quotas
# - Verify the rollout and resulting pod resources
