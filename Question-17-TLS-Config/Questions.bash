# Question:
# There is an existing deployment in the nginx-static namespace. The deployment contains a ConfigMap that supports
# TLSv1.2 and TLSv1.3 as well as a Secret for TLS.

# There is a service called nginx-service in the nginx-static namespace that is currently exposing the deployment.

# Task:
# 1. Configure the ConfigMap to only support TLSv1.3
# 2. Add the IP address of the service in /etc/hosts and name it ckaquestion.k8s.local
# 3. Verify everything is working using the following commands
    curl -vk --tls-max 1.2 https://ckaquestion.k8s.local # should fail
    curl -vk --tlsv1.3 https://ckaquestion.k8s.local # should work

# Video Link
