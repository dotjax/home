#!/bin/bash
set -euo pipefail

# s-bin-repo-sync.sh
# Syncs the bin directory from this repository to $HOME/bin

# Directory where this script is located
REPO_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER_BIN_DIR="$HOME/bin"

echo "Syncing scripts..."
echo "Source: $REPO_BIN_DIR"
echo "Dest:   $USER_BIN_DIR"

if [ ! -d "$USER_BIN_DIR" ]; then
    echo "Creating $USER_BIN_DIR..."
    mkdir -p "$USER_BIN_DIR"
fi

# Use cp to copy files (more portable than rsync)
# -a: archive mode (recursive, preserves permissions/timestamps)
# -u: update (only copy if source is newer)
# -v: verbose
cp -auv "$REPO_BIN_DIR"/* "$USER_BIN_DIR/"

echo "Sync complete."
