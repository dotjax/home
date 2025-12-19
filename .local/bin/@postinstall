#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# Performance Tuning & DNF Config
# -------------------------------------------------------
echo "→ Adding DNF performance parameters..."

# NOTE: This overwrites /etc/dnf/dnf.conf (it does not merge with existing settings).
# Intent: faster/more convenient DNF behavior on a personal desktop.

sudo tee /etc/dnf/dnf.conf >/dev/null <<'EOF'
[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=True
max_parallel_downloads=20
keepcache=True
EOF

# -------------------------------------------------------
# Debloating
# -------------------------------------------------------
echo "→ Executing targeted package removal..."

# Intent: remove workstation/enterprise/edge-case tooling you don't use (e.g., virtualization,
# containers, smartcard support, crash reporting, some GNOME extras).
#
# `|| true` makes this block non-fatal if some packages are already absent.

sudo dnf remove \
  abrt* \
  pcsc-lite pcsc-lite-libs ccid \
  virtualbox* vboxguest* vboxservice* \
  vmware-tools* open-vm-tools* \
  qemu-guest-agent qemu* libvirt* \
  podman* netavark* aardvark-dns* \
  virt-manager virt-install virt-viewer \
  ModemManager \
  passim mcelog avahi thermald \
  gssproxy uresourced low-memory-monitor \
  iscsi-initiator-utils \
  gnome-tour gnome-maps malcontent-control \
  yelp gnome-contacts \
  brltty hyperv-daemons stress-ng NetworkManager-adsl \
  NetworkManager-ppp NetworkManager-vpnc \
  || true

# Optional: remove enterprise login / Kerberos / domain-join tooling.
# Keep this if you ever need corporate SSO/domain join (AD/IPA/Kerberos).
# `|| true` keeps the script going if these packages aren't installed.
echo "→ Removing enterprise auth / domain join..."
sudo dnf remove \
  krb5-workstation \
  realmd adcli \
  oddjob oddjob-mkhomedir \
  sssd* \
  samba-winbind* \
  authselect-compat \
  openldap-clients \
  || true

#--------------------------------------------------------
# Useful packages and tools
#--------------------------------------------------------
echo "→ Installing useful packages, tools, and dev components..."
sudo dnf install \
  tmux \
  wget curl aria2 \
  git gcc gcc-c++ make rustc cargo \
  cmake ninja pkg-config \
  unzip tar pigz zstd p7zip p7zip-plugins \
  rsync strace perf \
  tldr \
  lm_sensors sysstat \
  traceroute netstat net-tools nmap \
  pciutils \
  smartmontools nvme-cli \
  || true
#  htop radeontop \
#  fastfetch \
#  stress-ng numactl \
#  ncdu btrfs-progs \
#  jq fd-find bat ripgrep \

# -------------------------------------------------------
# Repository Expansion
# -------------------------------------------------------
# echo "→ Activating RPM Fusion..."

# RPM Fusion: enables full multimedia codecs and other packages Fedora doesn't ship by default.
# Flathub: enables Flatpak apps from the main community remote.

sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "→ Activating Flathub..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub

# -------------------------------------------------------
# Multimedia & Gaming Foundation
# -------------------------------------------------------
# echo "→ Enabling full multimedia codecs (RPM Fusion)..."

# Swap codecs (don’t abort the whole script if ffmpeg-free isn’t installed)
sudo dnf swap ffmpeg-free ffmpeg --allowerasing || true

# Keep the multimedia group aligned over time (helps keep codecs/plugins consistent across updates)
sudo dnf group install --with-optional multimedia \
  --allowerasing \
  --setopt="install_weak_deps=False" \
  --exclude=PackageKit-gstreamer-plugin

#-------------------------------------------------------
# Mullvad VPN
#-------------------------------------------------------
echo "→ Installing Mullvad VPN..."
sudo dnf config-manager addrepo \
  --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo \
  || true
sudo dnf install mullvad-vpn \
  || true

# -------------------------------------------------------
# AI & Compute Stack (AMD)
# -------------------------------------------------------
# echo "→ Installing ROCm (AMD Compute) for 7900 XT..."

# ROCm enables AMD GPU compute for local AI workloads (e.g., PyTorch/Ollama).
sudo dnf install rocm-hip rocm-opencl rocminfo rocm-smi

# -------------------------------------------------------
# System Optimization
# -------------------------------------------------------
echo "→ Optimizing boot sequence..."

# Speeds boot on desktops by skipping "wait until network is online".
# Avoid disabling this if you have services that *require* network-online at boot.
sudo systemctl disable --now NetworkManager-wait-online.service

# -------------------------------------------------------
# Final Polish
# -------------------------------------------------------
echo "→ Finalizing..."

# Personal desktop UX conveniences (GNOME tweaks + a few common extensions)

sudo dnf install \
  gnome-extensions-app \
  gnome-shell-extension-dash-to-dock \
  gnome-tweaks \
  || true
#   gnome-shell-extension-user-theme \
#   gnome-shell-extension-appindicator \

# Set Hostname
# Sets the machine hostname shown in prompts/SSH/host discovery.
sudo hostnamectl set-hostname fedora

# Final Update & Clean
# Bring everything up to date and remove unused deps. Flatpak steps are kept strict so failures
# are visible (no `|| true`), since they can indicate repo/network problems.
sudo dnf update --refresh -y
sudo dnf autoremove -y
sudo dnf clean all
sudo flatpak repair
flatpak uninstall --unused -y
flatpak update -y
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "==================================================="
echo "          Complete. Reboot recommended.            "
echo "==================================================="
