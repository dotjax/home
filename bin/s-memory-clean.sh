#!/bin/bash
set -e

# s-memory-clean.sh
# Clears RAM caches and Swap space.
# Requires sudo privileges.

echo "=== Memory Cleanup ==="
echo "Current Memory Usage:"
free -h
echo "----------------------"

echo "1. Flushing file system buffers..."
sync

echo "2. Dropping caches (PageCache, dentries, inodes)..."
# We use 'sudo sh -c' because redirection (>) happens in the shell before sudo
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

echo "3. Clearing Swap..."
# Check if swap is actually being used to avoid unnecessary work
SWAP_USED=$(free | awk '/^Swap:/ {print $3}')

if [ "$SWAP_USED" != "0" ] && [ "$SWAP_USED" != "0B" ]; then
    echo "   Swap is in use ($SWAP_USED). Clearing..."
    echo "   WARNING: This moves swapped data back to RAM. Ensure you have enough free RAM."
    
    # Turn swap off (moves data to RAM) and then back on
    sudo swapoff -a && sudo swapon -a
    echo "   Swap cleared."
else
    echo "   Swap is already empty. Skipping."
fi

echo "----------------------"
echo "New Memory Usage:"
free -h
echo "=== Done ==="
