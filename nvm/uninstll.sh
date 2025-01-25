#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/nvmprofile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# 1. Remove NVM
brew remove --force nvm

# 2. Remove NVM's working directory
rm -rf ~/.nvm

# 3. Remove shell profile
if grep -q "$SOURCE_PROFILE" "$SHELL_RC"; then
    grep -vF "$SOURCE_PROFILE" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "NVM config successfully removed from $SHELL_RC"
    source $SHELL_RC
else
    echo "No NVM config found in $SHELL_RC. No changes made."
fi

echo "[NVM] Uninstallation completed."