# Install and run cri-dockerd
sudo dpkg -i cri-dockerd.deb
sudo systemctl enable --now cri-docker.service
sudo systemctl status cri-docker.service

# Set sysctl (make persistent)
sudo tee /etc/sysctl.d/kube.conf >/dev/null <<'EOF'
net.bridge.bridge-nf-call-iptables=1
net.ipv6.conf.all.forwarding=1
net.ipv4.ip_forward=1
net.netfilter.nf_conntrack_max=131072
EOF
sudo sysctl --system
