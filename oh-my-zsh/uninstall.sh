#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"

# 1. Remove zsh plugins by brew
brew remove \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-completions

# 2. Remove shell profile for brew zsh plugins
if grep -q "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    grep -vF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Zsh plugins config successfully removed from $SHELL_RC"
    source $SHELL_RC
else
    echo "No Zsh plugins config found in $SHELL_RC. No changes made."
    exit
fi

# 3. Remove oh-my-zsh by manual
echo "[OMZ] Not support to uninstall oh-my-zsh. Please enter the below command manually"
echo "uninstall_oh_my_zsh"