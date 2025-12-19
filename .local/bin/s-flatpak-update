#!/bin/bash

# Clean Flatpak, remove unused packages and update 
echo 'Cleaning Flatpak caches and temporary files...'
rm -rf "$HOME/.cache/flatpak"
find "$HOME/.var/app" -path '*/.cache' -prune -exec rm -rf {} + 2>/dev/null || true
sudo rm -rf /var/cache/flatpak
echo 'Remove unused Flatpak data...'
flatpak uninstall --unused
echo 'Running Flatpak repair...'
sudo flatpak repair
echo 'Update Flatpak...'
flatpak update