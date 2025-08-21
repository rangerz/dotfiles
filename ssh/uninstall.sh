#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
SSH_MUX_DIR="$HOME/.ssh/mux"
INCLUDE_CONFIG="Include $CUR_DIR/config"

# Remove the configuration
if grep -q "$INCLUDE_CONFIG" "$SSH_CONFIG"; then
    sed -i'' -e "/$INCLUDE_CONFIG/d" "$SSH_CONFIG"
    echo "SSH config successfully removed from $SSH_CONFIG"
else
    echo "No SSH config found in $SSH_CONFIG. No changes made."
    exit
fi

# Remove created directories
if [ -d "$SSH_MUX_DIR" ]; then
    rm -rf "$SSH_MUX_DIR"
    echo "Removed directory: $SSH_MUX_DIR"
fi

echo "[SSH] Uninstallation completed."
