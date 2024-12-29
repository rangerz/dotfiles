#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"

# Remove omz plugins by brew
if grep -q "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    grep -vF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Zsh plugins config successfully removed from $SHELL_RC"
else
    echo "No Zsh plugins config found in $SHELL_RC. No changes made."
    exit
fi

echo "[OMZ] Not support to uninstall oh-my-zsh. Please enter the below command manually"
echo "uninstall_oh_my_zsh"

