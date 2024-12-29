#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"
SHELL_PROFILE="$CUR_DIR/gitprofile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

if ! type git >/dev/null 2>&1; then
    echo "Git is not installed."
    exit
fi

if ! git config --get-all include.path | grep -q "$GIT_CONFIG"; then
    echo "No git config found in ~/.gitconfig. No changes made."
else
    git config --global --unset include.path "$GIT_CONFIG"
fi

# Remove the configuration
if grep -q "$SOURCE_PROFILE" "$SHELL_RC"; then
    grep -vF "$SOURCE_PROFILE" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Git config successfully removed from $SHELL_RC"
else
    echo "No git config found in $SHELL_RC. No changes made."
    exit
fi

echo "[Git] Uninstallation completed."