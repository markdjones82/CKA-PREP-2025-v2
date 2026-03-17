# Question SideCar

# Task
# Update the existing wordpress deployment adding a sidecar container named sidecar using the busybox:stable
# image to the existing pod
# The new sidecar container has to run the following command
"/bin/sh -c tail -f /var/log/wordpress.log"
# Use a volume mounted at /var/log to make the log file wordpress.log available to the co-located container

#Video link - https://youtu.be/3xraEGGQJDY
