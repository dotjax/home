#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# Append .py extension to file(s)
# Usage: s-rename-append-py <file> [file2] [file3] ...
#
# Intent: Rename files by appending .py extension.
# -------------------------------------------------------

if [ $# -eq 0 ]; then
    echo "Usage: s-rename-append-py <file> [file2] [file3] ..."
    echo "Appends .py extension to the specified file(s)"
    exit 1
fi

for file in "$@"; do
    if [ ! -e "$file" ]; then
        echo "Error: '$file' does not exist"
        continue
    fi
    
    if [ -d "$file" ]; then
        echo "Error: '$file' is a directory (skipping)"
        continue
    fi
    
    new_name="${file}.py"
    
    if [ -e "$new_name" ]; then
        echo "Error: '$new_name' already exists (skipping '$file')"
        continue
    fi
    
    mv "$file" "$new_name"
    echo "Renamed: $file -> $new_name"
done

