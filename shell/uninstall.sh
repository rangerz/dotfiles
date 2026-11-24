#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BOOTSTRAP_FILE="$CUR_DIR/shell.sh"
BOOTSTRAP_LINE="source $BOOTSTRAP_FILE"
RC_FILE="$HOME/.zshrc"

if grep -qxF "$BOOTSTRAP_LINE" "$RC_FILE"; then
    # Fixed-string match: the line holds a path whose "/" breaks a sed address; `|| true` keeps an emptied file
    grep -vxF "$BOOTSTRAP_LINE" "$RC_FILE" >"$RC_FILE.tmp" || true
    # cat (not mv) keeps the original file's mode and any symlink
    cat "$RC_FILE.tmp" >"$RC_FILE"
    rm -f "$RC_FILE.tmp"
    echo "Shell config successfully removed from $RC_FILE"
else
    echo "No shell config found in $RC_FILE. No changes made."
fi

echo "[Shell] Uninstallation completed."
