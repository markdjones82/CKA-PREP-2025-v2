#!/bin/bash
set -e

# Download CRI Dockerd Debian package to /root, matching typical exam setup
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.20/cri-dockerd_0.3.20.3-0.debian-bullseye_amd64.deb -O /root/cri-dockerd.deb

echo "CRI Dockerd package downloaded to /root/cri-dockerd.deb"
