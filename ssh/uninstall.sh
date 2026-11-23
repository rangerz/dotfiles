#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
SSH_MUX_DIR="$HOME/.ssh/mux"
INCLUDE_CONFIG="Include $CUR_DIR/config"

# Remove the configuration
if grep -qF "$INCLUDE_CONFIG" "$SSH_CONFIG"; then
    # Fixed-string match: the line holds a path whose "/" breaks a sed address; `|| true` keeps an emptied file
    grep -vxF "$INCLUDE_CONFIG" "$SSH_CONFIG" >"$SSH_CONFIG.tmp" || true
    # cat (not mv) keeps the original file's mode and any symlink
    cat "$SSH_CONFIG.tmp" >"$SSH_CONFIG"
    rm -f "$SSH_CONFIG.tmp"
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
