#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"
SHELL_PROFILE="$CUR_DIR/gitprofile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# 1. Install git
if command -v brew &>/dev/null; then
    brew install git
fi

# 2. Setup gitconfig
if git config --get-all include.path | grep -q "$GIT_CONFIG"; then
    echo "Git config already exists in ~/.gitconfig. No changes made."
else
    git config --global --add include.path "$GIT_CONFIG"
fi

# 3. Setup shell profile
if ! grep -qF "$SOURCE_PROFILE" "$SHELL_RC"; then
    echo "$SOURCE_PROFILE" >> "$SHELL_RC"
    echo "shell config successfully updated into $SHELL_RC"
    #source $SHELL_RC
else
    echo "shell config already exists in $SHELL_RC. No changes made."
fi

echo "[Git] Installation completed."
