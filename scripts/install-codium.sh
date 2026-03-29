#!/bin/bash
# ============================================================
# install-codium.sh - Install VSCodium in the exam environment
#
# VSCodium provides a VS Code-like editor inside the Killercoda
# simulated desktop environment.
#
# IMPORTANT: A paid Killercoda subscription is required
#     for the simulated desktop (GUI) feature. Without it,
#     the desktop will not be available and codium cannot be
#     launched graphically.
#
# Usage:
#   scripts/install-codium.sh
# ============================================================
set -euo pipefail

echo "======================================================"
echo " Installing VSCodium"
echo "======================================================"
echo ""
echo "NOTE: A paid Killercoda subscription is required"
echo "    for the simulated desktop environment."
echo ""

# 1. Add VSCodium GPG key
echo "Adding VSCodium GPG key..."
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  | gpg --dearmor \
  | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

# 2. Add VSCodium apt source
echo "Adding VSCodium apt repository..."
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
  | sudo tee /etc/apt/sources.list.d/vscodium.sources

# 3. Install VSCodium
echo "Installing codium..."
sudo apt update -q && sudo apt install -y codium

echo ""
echo "[OK] VSCodium installed successfully!"
echo ""
echo "To launch VSCodium in the simulated desktop environment:"
echo ""
echo "  codium --no-sandbox --user-data-dir ."
echo ""
echo "This opens VSCodium in the current directory."
echo "Run it from inside your repo: cd ~/CKA-PREP-2025-v2 && codium --no-sandbox --user-data-dir ."
