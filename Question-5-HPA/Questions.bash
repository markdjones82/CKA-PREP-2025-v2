# Question HPA
# Create a new HorizontalPodAutoScaler(HPA) named apache-server in the autoscale namespace

# Task
# 1. The HPA must target the existing deployment called apache-deployment in the autoscale namespace
# 2. Set the HPA to target for 50% CPU usage per Pod
# 3. Configure the HPA to have a minimum of 1 pod and a maximum of 4 pods
# 4. Set the downscale stabilization window to 30 seconds

# Video Link - https://youtu.be/YGkARVFKtmM

#Documentation Reference
# Tip: Navigate the documentation manually to build familiarity with its structure
# (hpa) Tasks -> Run Application -> HorizontalPodAutoscaling Walkthrough
# https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
# (downscale) Concepts -> Workloads -> Horizontal Pod Autoscaling
# https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/