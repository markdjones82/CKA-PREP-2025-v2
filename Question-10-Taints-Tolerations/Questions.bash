# Question: Taints & Tolerances

# Tasks:
# 1. Add a taint to node01 so tht no normal pods can be scheduled in this node. key=PERMISSION, value=granted, Type=NoSchedule
# 2. Schedule a Pod on node01 adding the correct toleration to the spec so it can be deployed

# Video Link - https://youtu.be/oy6Mdqt1-jk

#Documentation Reference
# Tip: Navigate the documentation manually to build familiarity with its structure
# Concepts -> Scheduling, Preemption and Eviction -> Taints and Tolerations
# https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/