#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/profile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# Setup shell profile
if ! grep -qF "$SOURCE_PROFILE" "$SHELL_RC"; then
    echo "$SOURCE_PROFILE" >> "$SHELL_RC"
    echo "Shell config successfully updated into $SHELL_RC"
    source $SHELL_RC
else
    echo "Shell config already exists in $SHELL_RC. No changes made."
fi

echo "[Shell] Installation completed."