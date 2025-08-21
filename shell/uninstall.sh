#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BOOTSTRAP_FILE="$CUR_DIR/shell.sh"
BOOTSTRAP_LINE="source $BOOTSTRAP_FILE"
RC_FILE="$HOME/.zshrc"

if grep -q "$BOOTSTRAP_LINE" "$RC_FILE"; then
    sed -i'' -e "/$BOOTSTRAP_LINE/d" "$RC_FILE"
    echo "Shell config successfully removed from $RC_FILE"
else
    echo "No shell config found in $RC_FILE. No changes made."
fi

echo "[Shell] Uninstallation completed."
