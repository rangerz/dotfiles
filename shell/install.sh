#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BOOTSTRAP_FILE="$CUR_DIR/shell.sh"
BOOTSTRAP_LINE="source $BOOTSTRAP_FILE"
RC_FILE="$HOME/.zshrc"

if ! grep -qF "$BOOTSTRAP_LINE" "$RC_FILE"; then
    echo "$BOOTSTRAP_LINE" >>"$RC_FILE"
    echo "Shell config successfully updated into $RC_FILE"
else
    echo "Shell config already exists in $RC_FILE. No changes made."
fi

echo "[Shell] Installation completed."
echo "[Shell] Please restart your terminal or run 'exec zsh'"
