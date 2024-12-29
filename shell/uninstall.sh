#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/profile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# Remove the configuration
if grep -q "$SOURCE_PROFILE" "$SHELL_RC"; then
    grep -vF "$SOURCE_PROFILE" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Shell config successfully removed from $SHELL_RC"
else
    echo "No shell config found in $SHELL_RC. No changes made."
    exit
fi

echo "[Shell] Uninstallation completed."