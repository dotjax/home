#!/usr/bin/env bash
# Rescan all non-NVMe storage on Linux (Fedora-friendly).
# - Reloads udev rules and triggers device add events
# - Rescans all SCSI hosts
# - Re-reads partition tables on sd*/vd*/xvd*/hd* devices
# Skips NVMe entirely.

set -euo pipefail

log() { printf '[rescan] %s\n' "$*"; }

usage() {
  cat <<'EOF'
Usage:
  _rescan [--dry-run] [--verbose] [--rescan-pci]

Description:
  Rescans non-NVMe storage devices so newly connected/changed disks show up.
  --dry-run prints actions only.

Options:
  --dry-run     Print what would be executed, but do not change anything.
  --verbose     Show command output and errors (useful for debugging).
  --rescan-pci  Also rescan PCI bus (for hotplugged HBA/RAID controllers).
  -h, --help    Show this help.
EOF
}

DRY_RUN=0
VERBOSE=1
RESCAN_PCI=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --verbose) VERBOSE=1 ;;
    --rescan-pci) RESCAN_PCI=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 2
      ;;
  esac
done

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: $*"
    return 0
  fi
  if [[ "$VERBOSE" -eq 1 ]]; then
    sudo "$@"
  else
    sudo "$@" 2>/dev/null || true
  fi
}

write_sysfs() {
  local path="$1"
  local value="$2"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: write '$value' > $path"
    return 0
  fi
  if [[ ! -e "$path" ]]; then
    [[ "$VERBOSE" -eq 1 ]] && log "WARNING: sysfs path does not exist: $path"
    return 1
  fi
  echo "$value" | sudo tee "$path" >/dev/null
}

reload_udev_rules() {
  log "Reloading udev rules"
  run udevadm control --reload
  run udevadm control --reload-rules
}

trigger_udev_block_add() {
  log "Triggering udev for block subsystem"
  run udevadm trigger --subsystem-match=block --action=add
  log "Waiting for udev to settle..."
  run udevadm settle --timeout=10
}

rescan_scsi_hosts() {
  log "Rescanning all SCSI hosts"
  for host in /sys/class/scsi_host/host*; do
    [[ -e "$host/scan" ]] || continue
    local hostnum
    hostnum="$(basename "$host")"
    [[ "$VERBOSE" -eq 1 ]] && log "  Scanning $hostnum..."
    # Standard SCSI scan request: "- - -" (all channels/targets/luns)
    write_sysfs "$host/scan" "- - -"
  done
}

is_skipped_block_device() {
  case "$1" in
    nvme*|loop*|zram*|ram*|dm-*|md*|sr*) return 0 ;;
    *) return 1 ;;
  esac
}

reread_partition_tables() {
  log "Re-reading partition tables (non-NVMe)"
  for sysdev in /sys/block/*; do
    local devbase
    devbase="$(basename "$sysdev")"
    if is_skipped_block_device "$devbase"; then
      continue
    fi

    local dev
    dev="/dev/$devbase"

    if [[ -b "$dev" ]]; then
      # Try blockdev first; fall back to partprobe if needed
      if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: blockdev --rereadpt $dev"
      else
        if ! sudo blockdev --rereadpt "$dev" 2>/dev/null; then
          [[ "$VERBOSE" -eq 1 ]] && log "  blockdev failed for $dev, trying partprobe..."
          sudo partprobe -s "$dev" 2>/dev/null || true
        fi
      fi
    fi
  done
}

restart_udisks2() {
  log "Restarting udisks2 (desktop disk management)"
  run systemctl restart udisks2.service
}

print_summary() {
  log "Done. Current view:"
  run lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,LABEL,MODEL -e 7,11,1,2,230,259
}

capture_devices() {
  lsblk --nodeps -no NAME,SIZE,MODEL 2>/dev/null | grep -vE '^(loop|zram|ram|dm-|md|sr)' || true
}

compare_devices() {
  local before="$1"
  local after="$2"
  local new_devices
  new_devices=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))
  if [[ -n "$new_devices" ]]; then
    log "Newly discovered devices:"
    echo "$new_devices" | while IFS= read -r line; do
      [[ -n "$line" ]] && log "  + $line"
    done
  else
    log "No new devices discovered"
  fi
}

log "Capturing current device list..."
DEVICES_BEFORE=$(capture_devices)

reload_udev_rules
trigger_udev_block_add
rescan_scsi_hosts

# Optionally rescan PCI bus if requested
if [[ "$RESCAN_PCI" -eq 1 ]]; then
  log "Rescanning PCI bus (for hotplugged controllers)"
  run udevadm trigger --subsystem-match=pci --action=add
  run udevadm settle --timeout=10
fi

reread_partition_tables

log "Triggering udev again to pick up new partitions"
run udevadm trigger --subsystem-match=block --action=add
log "Waiting for udev to settle..."
run udevadm settle --timeout=10

restart_udisks2

log "Comparing device lists..."
DEVICES_AFTER=$(capture_devices)
compare_devices "$DEVICES_BEFORE" "$DEVICES_AFTER"
echo ""

print_summary
