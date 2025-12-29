#!/usr/bin/env bash
set -euo pipefail

echo "=== System Health Check ==="
echo ""

# -------------------------------------------------------
# System Info
# -------------------------------------------------------
echo "→ System Information"
echo "Hostname: $(hostnamectl hostname)"
echo "Uptime: $(uptime -p)"
echo "Kernel: $(uname -r)"
echo ""

# -------------------------------------------------------
# CPU
# -------------------------------------------------------
echo "→ CPU Status"
echo "Load Average (1m, 5m, 15m): $(uptime | awk -F'load average:' '{print $2}')"
grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^ *//' | xargs echo "CPU:"

sensors 2>/dev/null | grep -i "Package id 0" || echo "CPU temp not available"
echo ""

# -------------------------------------------------------
# Memory
# -------------------------------------------------------
echo "→ Memory Usage"
free -h | grep -E 'Mem|Swap'
echo ""

# -------------------------------------------------------
# GPU (AMD ROCm)
# -------------------------------------------------------
echo "→ GPU Status (AMD 7900 XT)"
rocm-smi --showtemp --showmeminfo vram --showuse 2>/dev/null || echo "rocm-smi unavailable"
echo ""

# -------------------------------------------------------
# Disk Space
# -------------------------------------------------------
echo "→ Disk Space"
df -h / /home 2>/dev/null | grep -v "tmpfs"
echo ""

# -------------------------------------------------------
# Disk Health (SMART)
# -------------------------------------------------------
echo "→ Disk Health (SMART)"
# NVMe drives
sudo smartctl -H /dev/nvme0n1 2>/dev/null | grep -E "SMART overall-health|result:" || echo "NVMe SMART unavailable"
# SATA drives (if present)
sudo smartctl -H /dev/sda 2>/dev/null | grep -E "SMART overall-health|result:" || true
sudo smartctl -H /dev/sdb 2>/dev/null | grep -E "SMART overall-health|result:" || true
echo ""

# -------------------------------------------------------
# Failed Services
# -------------------------------------------------------
echo "→ Failed Systemd Services"
systemctl --failed --no-pager || echo "No failed services"
echo ""

# -------------------------------------------------------
# Network
# -------------------------------------------------------
echo "→ Network Status"
ip -br addr show | grep -E 'UP|UNKNOWN' || echo "No active network interfaces"
echo ""

echo "=== Health Check Complete ==="
