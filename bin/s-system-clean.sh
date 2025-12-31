#!/usr/bin/env bash
set -euo pipefail

echo "=== Fedora Maintenance Script ==="
echo "Running as: $(whoami)"
echo ""

# Show initial disk space
echo "Disk space before cleanup:"
df -h / | grep -E '^Filesystem|/'
echo ""

# Clean journal logs
echo "Cleaning journal logs (retaining 3 days, max 500MB)..."
sudo journalctl --vacuum-time=3d --vacuum-size=500M

# Empty Trash
echo "Emptying Trash..."
rm -rf "$HOME/.local/share/Trash/"*

# Flatpak cleanup
echo "Cleaning Flatpak (unused runtimes)..."
flatpak repair --user
sudo flatpak repair
flatpak uninstall --unused -y

# Clean orphaned Flatpak data
if [ -d "$HOME/.var/app" ]; then
    echo "Cleaning orphaned Flatpak data in ~/.var/app..."
    for dir in "$HOME/.var/app"/*; do
        [ -d "$dir" ] || continue
        appid=$(basename "$dir")
        if ! flatpak info "$appid" >/dev/null 2>&1; then
            echo "  Removing orphaned data for $appid..."
            rm -rf "$dir"
        fi
    done
fi

# Flatpak cache clean up
rm -rf "$HOME/.cache/flatpak"
find "$HOME/.var/app" -path '*/.cache' -prune -exec rm -rf {} + 2>/dev/null || true
sudo rm -rf /var/cache/flatpak

# Targeted cache cleanup (safe)
echo "Cleaning user-level caches (targeted)..."
# Clean browser caches older than 30 days
find ~/.cache/mozilla ~/.cache/chromium ~/.cache/google-chrome -type f -mtime +30 -delete 2>/dev/null || true
# Clean old thumbnails
find ~/.cache/thumbnails -type f -mtime +30 -delete 2>/dev/null || true
# Clean pip cache
rm -rf ~/.cache/pip/* 2>/dev/null || true
# Clean temp directories in cache
find ~/.cache -type f -name "*.tmp" -delete 2>/dev/null || true

# Clean Python bytecode
echo "Cleaning __pycache__ directories..."
find ~ -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Clean broken symlinks
echo "Cleaning broken symlinks in home directory..."
find ~ -maxdepth 3 -xtype l -delete 2>/dev/null || true

# DNF Cleanup
echo "Cleaning DNF cache..."
sudo dnf clean all

# Show final disk space
echo ""
echo "Disk space after cleanup:"
df -h / | grep -E '^Filesystem|/'
echo ""

echo "=== Maintenance Complete! ==="

