# Question SideCar

# Task
# Update the existing wordpress deployment adding a sidecar container named sidecar using the busybox:stable
# image to the existing pod
# The new sidecar container has to run the following command (as given by the exam task):
"/bin/sh -c tail -f /var/log/wordpress.log"
# Note: In your solution use `tail -F` (capital F) – it follows log files across
# rotation and re-creation, whereas `-f` (lowercase) can miss logs after rotation.

#Video link - https://youtu.be/3xraEGGQJDY

#Documentation Reference
# Tip: Navigate the documentation manually to build familiarity with its structure
# Concepts -> Workloads -> pod -> Sidecar Containers
# https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/