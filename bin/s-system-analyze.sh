#!/bin/bash

# s-system-analyze.sh
# Deeply analyzes the system for leftovers, orphans, and inefficiencies.

echo "=== System Deep Analysis ==="
echo "Date: $(date)"
echo "----------------------------"

# 1. Unused Packages (DNF)
echo "[1] Unused DNF Packages (Leaves)"
# Packages that were installed as dependencies but are no longer needed
LEAVES=$(dnf repoquery --unneeded --queryformat '%{name}')
if [ -n "$LEAVES" ]; then
    echo "Found $(echo "$LEAVES" | wc -l) unneeded packages:"
    echo "$LEAVES" | head -n 10
    [ $(echo "$LEAVES" | wc -l) -gt 10 ] && echo "... and more."
else
    echo "No unneeded DNF packages found."
fi
echo ""

# 2. Unused Flatpaks
echo "[2] Unused Flatpak Runtimes & Data"
# Use echo n to simulate a dry run since --dry-run doesn't exist
UNUSED_FLATPAK=$(echo n | flatpak uninstall --unused 2>/dev/null)
if [[ "$UNUSED_FLATPAK" == *"Nothing unused"* || -z "$UNUSED_FLATPAK" ]]; then
    echo "No unused Flatpak runtimes."
else
    echo "$UNUSED_FLATPAK" | grep -v "pinned" | grep -v "Proceed with"
fi

# Check for orphaned data in ~/.var/app
echo "Checking for orphaned Flatpak data in ~/.var/app..."
for dir in ~/.var/app/*; do
    [ -d "$dir" ] || continue
    appid=$(basename "$dir")
    if ! flatpak list --app --columns=application | grep -q "^$appid$"; then
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo "  ! $appid ($size) - Data exists but app is not installed."
    fi
done
echo ""

# 3. Orphaned Configuration & Data
echo "[3] Potential Orphaned Data in .config and .local/share"
# This looks for directories in .config/.local that don't have a corresponding binary in PATH
echo "Checking for directories that might not belong to any installed command..."
for dir in ~/.config/* ~/.local/share/*; do
    [ -d "$dir" ] || continue
    base=$(basename "$dir")
    # Skip common/system directories
    [[ "$base" =~ ^(gnome|gtk|ibus|dconf|pulse|systemd|trash|applications|icons|fonts|themes|backgrounds|flatpak|containers|Kvantum|mpd|ncmpcpp|nvim|sway|waybar|wofi|foot|htop|tmux)$ ]] && continue
    
    if ! command -v "$base" >/dev/null 2>&1 && ! command -v "${base,,}" >/dev/null 2>&1; then
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo "  ? $base ($size) - No matching command found in PATH."
    fi
done

# Check for broken .desktop files
echo "Checking for broken .desktop entries..."
for f in ~/.local/share/applications/*.desktop; do
    [ -f "$f" ] || continue
    exec_path=$(grep -P "^Exec=" "$f" | cut -d'=' -f2 | awk '{print $1}')
    if [[ -n "$exec_path" && ! "$exec_path" =~ ^/ ]] && ! command -v "$exec_path" >/dev/null 2>&1; then
        echo "  ! $(basename "$f") - Points to missing command: $exec_path"
    fi
done
echo ""

# 4. RPM Artifacts
echo "[4] RPM Artifacts (.rpmnew / .rpmsave)"
RPM_ARTIFACTS=$(sudo find /etc -name "*.rpmnew" -o -name "*.rpmsave" 2>/dev/null)
if [ -n "$RPM_ARTIFACTS" ]; then
    echo "Found leftover RPM configuration files:"
    echo "$RPM_ARTIFACTS"
else
    echo "No .rpmnew or .rpmsave files found in /etc."
fi
echo ""

# 5. Cache Analysis
echo "[5] Cache Usage"
echo "User Cache (~/.cache): $(du -sh ~/.cache 2>/dev/null | cut -f1)"
echo "System Cache (/var/cache): $(sudo du -sh /var/cache 2>/dev/null | cut -f1)"
echo "Top 5 largest user caches:"
du -sh ~/.cache/* 2>/dev/null | sort -hr | head -n 5
echo ""

# 6. Memory & Swap
echo "[6] Memory & Swap Analysis"
free -h
echo ""
echo "Top 5 Memory-consuming processes:"
ps aux --sort=-%mem | head -n 6 | awk '{print $4"% MEM\t"$11}'
echo ""

# 7. Zombie Processes
echo "[7] Zombie Processes"
ZOMBIES=$(ps aux | awk '$8=="Z"')
if [ -n "$ZOMBIES" ]; then
    echo "Found zombie processes:"
    echo "$ZOMBIES"
else
    echo "No zombie processes found."
fi
echo ""

# 8. Systemd Analysis (System & User)
echo "[8] Systemd Analysis"
echo "--- System Level ---"
FAILED_SYS=$(systemctl list-units --state=failed --no-legend)
if [ -n "$FAILED_SYS" ]; then
    echo "Failed system units:"
    echo "$FAILED_SYS"
else
    echo "No failed system units."
fi

# Check for broken symlinks in systemd search paths
echo "Checking for broken systemd unit symlinks..."
find /etc/systemd/system /usr/lib/systemd/system -xtype l -ls 2>/dev/null || echo "  None found."

echo ""
echo "--- User Level ---"
FAILED_USER=$(systemctl --user list-units --state=failed --no-legend)
if [ -n "$FAILED_USER" ]; then
    echo "Failed user units:"
    echo "$FAILED_USER"
else
    echo "No failed user units."
fi

# Check for broken symlinks in user systemd search paths
find ~/.config/systemd/user -xtype l -ls 2>/dev/null || echo "  No broken user unit symlinks."
echo ""

# 9. Broken Symlinks
echo "[9] Broken Symlinks in Home"
find ~ -maxdepth 3 -xtype l -ls 2>/dev/null || echo "None found."
echo ""

# 10. Kernel & System Artifacts
echo "[10] Kernel & System Artifacts"
echo "Installed Kernels:"
rpm -q kernel
echo ""

echo "Checking for __pycache__ directories (User Home):"
PYCACHE_COUNT=$(find ~ -name "__pycache__" -type d 2>/dev/null | wc -l)
if [ "$PYCACHE_COUNT" -gt 0 ]; then
    echo "  Found $PYCACHE_COUNT __pycache__ directories."
else
    echo "  No __pycache__ directories found."
fi

echo "Checking /lost+found (requires sudo):"
sudo ls /lost+found 2>/dev/null || echo "  /lost+found is empty or inaccessible."

echo "----------------------------"
echo "Analysis Complete."
echo "Use s-system-clean.sh or s-memory-clean.sh to address some of these findings."
