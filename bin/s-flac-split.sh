#!/bin/bash

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed. Run: sudo dnf install fzf"
    exit 1
fi

echo "Step 1: Select the .cue file"
CUE_FILE=$(find . -maxdepth 1 -name "*.cue" | fzf --prompt="Select CUE: ")

# Exit if no file selected
[[ -z "$CUE_FILE" ]] && exit

echo "Step 2: Select the .flac file"
FLAC_FILE=$(find . -maxdepth 1 -name "*.flac" | fzf --prompt="Select FLAC: ")

[[ -z "$FLAC_FILE" ]] && exit

# Execute splitting
echo "Splitting $FLAC_FILE..."
shnsplit -f "$CUE_FILE" -o flac -t "%n - %t" "$FLAC_FILE"

# Apply tags
echo "Applying metadata tags..."
# This targets the newly created files (usually starting with numbers)
cuetag.sh "$CUE_FILE" [0-9][0-9]*.flac

echo "Done!"
