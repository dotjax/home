#!/usr/bin/env bash
set -euo pipefail

echo "=== Ollama Uninstall (official install cleanup) ==="
echo ""

echo "→ Stopping and disabling service"
sudo systemctl stop ollama || true
sudo systemctl disable ollama || true
sudo systemctl kill ollama || true
sudo systemctl reset-failed ollama || true

echo "→ Removing systemd service units"
sudo rm -f /etc/systemd/system/ollama.service || true
sudo rm -f /lib/systemd/system/ollama.service || true
sudo rm -f /usr/lib/systemd/system/ollama.service || true
sudo systemctl daemon-reload || true

echo "→ Removing binaries and symlinks"
sudo rm -f /usr/local/bin/ollama || true
sudo rm -f /usr/bin/ollama || true
sudo rm -f /bin/ollama || true
sudo rm -f /opt/ollama/ollama || true

echo "→ Removing installation directories"
sudo rm -rf /usr/local/lib/ollama || true
sudo rm -rf /usr/local/ollama || true
sudo rm -rf /usr/lib/ollama || true
sudo rm -rf /opt/ollama || true

echo "→ Removing data and configs"
sudo rm -rf /var/lib/ollama || true
sudo rm -rf /etc/ollama || true
rm -rf ~/.ollama || true

echo "→ Clearing cache and temporary files"
sudo rm -rf /var/cache/ollama || true
sudo rm -rf /var/tmp/ollama || true

echo "→ Removing desktop entries and shared assets"
sudo rm -f /usr/share/applications/ollama.desktop || true
sudo rm -rf /usr/share/ollama || true

echo "→ Removing user from ollama group"
sudo gpasswd -d $(whoami) ollama 2>/dev/null || true

echo "→ Removing ollama system user and group"
sudo userdel ollama 2>/dev/null || true
sudo groupdel ollama 2>/dev/null || true

echo "→ Flushing journal logs for ollama"
sudo journalctl -u ollama --rotate 2>/dev/null || true
sudo journalctl -u ollama --vacuum-time=1s 2>/dev/null || true

echo "→ Verification"
command -v ollama >/dev/null 2>&1 && echo "WARN: ollama still in PATH" || echo "OK: ollama binary removed"
systemctl status ollama >/dev/null 2>&1 && echo "WARN: ollama service still present" || echo "OK: ollama service removed"
id ollama >/dev/null 2>&1 && echo "WARN: ollama user still exists" || echo "OK: ollama user removed"
getent group ollama >/dev/null 2>&1 && echo "WARN: ollama group still exists" || echo "OK: ollama group removed"

echo ""
echo "=== Uninstall complete ==="
echo ""
echo "NOTE: GPU drivers (NVIDIA CUDA/AMD ROCm) and kernel modules were NOT removed"
echo "      as they may be used by other applications. Remove manually if needed."
echo ""
echo "NOTE: /etc/modules-load.d/nvidia.conf was NOT removed to preserve NVIDIA"
echo "      module loading configuration. Remove manually if no longer needed."
