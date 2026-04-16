# Question 19: WordPress Deployment — Properly Size Resource Requests

# SCENARIO:
# A WordPress deployment in namespace 'relative-fawn' has 3 replicas.
# There is also a monitoring-agent deployment running in the same namespace.

# TASK:
# Edit the WordPress deployment so that each pod's resource requests
# equally divide the node's available resources among the 3 replicas.
# Limits do not need to be changed.

