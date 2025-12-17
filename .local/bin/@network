#!/usr/bin/env bash
set -euo pipefail

echo "=== Network Information ==="
echo ""

# -------------------------------------------------------
# Public IP
# -------------------------------------------------------
echo "→ Public IP Address"
curl -s ifconfig.me || echo "Unable to retrieve public IP"
echo ""
echo ""

# -------------------------------------------------------
# Local Network Interfaces
# -------------------------------------------------------
echo "→ Network Interfaces"
ip -br addr show
echo ""

# -------------------------------------------------------
# Default Gateway
# -------------------------------------------------------
echo "→ Default Gateway"
ip route | grep default || echo "No default gateway found"
echo ""

# -------------------------------------------------------
# DNS Servers
# -------------------------------------------------------
echo "→ DNS Servers"
resolvectl status | grep "DNS Servers" | head -n5 || cat /etc/resolv.conf | grep nameserver || echo "DNS info unavailable"
echo ""

# -------------------------------------------------------
# Active Connections
# -------------------------------------------------------
echo "→ Active Network Connections (established)"
ss -tunp state established 2>/dev/null | head -n20 || echo "Unable to list connections"
echo ""

# -------------------------------------------------------
# Listening Ports
# -------------------------------------------------------
echo "→ Listening Ports"
ss -tunlp 2>/dev/null | grep LISTEN | head -n15 || echo "Unable to list listening ports"
echo ""

# -------------------------------------------------------
# Network Statistics
# -------------------------------------------------------
echo "→ Network Statistics (RX/TX)"
ip -s link show | grep -E "^\s*[0-9]+:|RX:|TX:" | head -n20
echo ""

# -------------------------------------------------------
# Firewall Status
# -------------------------------------------------------
echo "→ Firewall Status"
sudo firewall-cmd --state 2>/dev/null || echo "Firewall status unavailable"
sudo firewall-cmd --get-active-zones 2>/dev/null || true
echo ""

# -------------------------------------------------------
# WiFi Information (if applicable)
# -------------------------------------------------------
echo "→ WiFi Status"
nmcli device wifi list 2>/dev/null | head -n10 || echo "No WiFi devices or NetworkManager unavailable"
echo ""

# -------------------------------------------------------
# Bandwidth Usage
# -------------------------------------------------------
echo "→ Current Bandwidth Usage"
sar -n DEV 1 1 2>/dev/null | grep -E "Average|enp7s0|wl" || echo "sar not available (install sysstat)"
echo ""

echo "=== Network Check Complete ==="
