#!/usr/bin/env bash
set -euo pipefail

echo "== Stopping MPD (user + system) =="
systemctl --user stop mpd.service 2>/dev/null || true
sudo systemctl stop mpd.service 2>/dev/null || true

echo "== Disabling and masking MPD (user + system) =="
systemctl --user disable mpd.service 2>/dev/null || true
systemctl --user mask mpd.service 2>/dev/null || true
sudo systemctl disable mpd.service 2>/dev/null || true
sudo systemctl mask mpd.service 2>/dev/null || true

echo "== Removing systemd unit files =="
rm -f ~/.config/systemd/user/mpd.service
rm -rf ~/.config/systemd/user/mpd.service.d
sudo rm -f /usr/lib/systemd/system/mpd.service
sudo rm -f /etc/systemd/system/mpd.service
sudo rm -rf /etc/systemd/system/mpd.service.d

echo "== Reloading systemd =="
systemctl --user daemon-reload
sudo systemctl daemon-reload

echo "== Killing any remaining mpd processes =="
pkill -u "$USER" mpd 2>/dev/null || true
sudo pkill mpd 2>/dev/null || true

echo "== Removing all MPD data and config =="
rm -rf ~/.mpd
rm -rf ~/.config/mpd
rm -rf ~/.config/ncmpcpp

echo "== Removing packages =="
sudo dnf remove -y mpd ncmpcpp || true

echo "== Done. MPD is fully removed."
