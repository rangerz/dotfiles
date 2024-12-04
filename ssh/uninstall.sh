#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
SSH_MUX_DIR="$HOME/.ssh/mux"
INCLUDE_CONFIG="Include $CUR_DIR/config"

# Remove the configuration
if grep -q "$INCLUDE_CONFIG" "$SSH_CONFIG"; then
    grep -vF "$INCLUDE_CONFIG" "$SSH_CONFIG" > "$SSH_CONFIG.tmp" && mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
    echo "Vim config successfully removed from $SSH_CONFIG"
else
    echo "No vim config found in $SSH_CONFIG. No changes made."
    exit
fi

# Remove created directories
if [ -d "$SSH_MUX_DIR" ]; then
    rm -rf "$SSH_MUX_DIR"
    echo "Removed directory: $SSH_MUX_DIR"
fi

echo "[SSH] Uninstallation completed."