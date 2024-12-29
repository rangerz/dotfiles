#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/profile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# Check if the configuration already exists
if ! grep -qF "$SOURCE_PROFILE" "$SHELL_RC"; then
    echo "$SOURCE_PROFILE" >> "$SHELL_RC"
    echo "shell config successfully updated into $SHELL_RC"
else
    echo "shell config already exists in $SHELL_RC. No changes made."
    exit
fi

echo "[Shell] Installation completed."

echo "Reload $SHELL"
exec $SHELL