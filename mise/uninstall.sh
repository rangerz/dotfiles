#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
MISE_PROFILE="$CUR_DIR/miseprofile"
SOURCE_PROFILE="source $MISE_PROFILE"
SHELL_RC="$HOME/.zshrc"

# 1. Remove mise
if command -v brew &>/dev/null; then
    brew remove --zap mise
    #rm -rf ~/.local/share/mise
    #rm -rf ~/.cache/mise 
    #rm -rf ~/.config/mise
fi

if command -v apt &>/dev/null; then
    sudo apt uninstall -y mise
fi

# 2. Remove shell profile
if grep -q "$SOURCE_PROFILE" "$SHELL_RC"; then
    grep -vF "$SOURCE_PROFILE" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Shell config successfully removed from $SHELL_RC"
    source $SHELL_RC
else
    echo "No shell config found in $SHELL_RC. No changes made."
fi

echo "[Shell] Uninstallation completed."
