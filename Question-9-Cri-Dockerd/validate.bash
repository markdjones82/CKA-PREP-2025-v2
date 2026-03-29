#!/bin/bash
# Validation script for Question 9 – Cri-Dockerd
set -uo pipefail

PASS=0
FAIL=0
TOTAL=0

check() {
  local description="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "  ❌ FAIL: $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "======================================"
echo " Validating Question 9: Cri-Dockerd"
echo "======================================"

# 1. cri-dockerd package is installed
check "cri-dockerd package is installed" \
  bash -c 'dpkg -l cri-dockerd 2>/dev/null | grep -q "^ii"'

# 2. cri-docker service is enabled
check "cri-docker service is enabled" \
  bash -c 'systemctl is-enabled cri-docker.service 2>/dev/null | grep -q enabled'

# 3. cri-docker service is active/running
check "cri-docker service is active (running)" \
  bash -c 'systemctl is-active cri-docker.service 2>/dev/null | grep -q active'

# 4. net.bridge.bridge-nf-call-iptables = 1
check "sysctl net.bridge.bridge-nf-call-iptables = 1" \
  bash -c '[[ "$(sysctl -n net.bridge.bridge-nf-call-iptables 2>/dev/null)" == "1" ]]'

# 5. net.ipv6.conf.all.forwarding = 1
check "sysctl net.ipv6.conf.all.forwarding = 1" \
  bash -c '[[ "$(sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null)" == "1" ]]'

# 6. net.ipv4.ip_forward = 1
check "sysctl net.ipv4.ip_forward = 1" \
  bash -c '[[ "$(sysctl -n net.ipv4.ip_forward 2>/dev/null)" == "1" ]]'

# 7. net.netfilter.nf_conntrack_max = 131072
check "sysctl net.netfilter.nf_conntrack_max = 131072" \
  bash -c '[[ "$(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null)" == "131072" ]]'

# 8. Settings are persistent (exist in sysctl config)
check "Sysctl settings are persisted in /etc/sysctl.d/" \
  bash -c 'grep -rq "net.bridge.bridge-nf-call-iptables" /etc/sysctl.d/ 2>/dev/null || grep -q "net.bridge.bridge-nf-call-iptables" /etc/sysctl.conf 2>/dev/null'

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
