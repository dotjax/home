#!/bin/bash
set -euo pipefail

echo "This script is mean to be run from the repository root. It will not work otherwise and may overwrite files unintentionally."

cp -auv bin/* ~/bin/

echo "Sync complete."
