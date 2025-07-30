#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"

#[ ! -n "$ZSH_VERSION" ] || { echo "You are not using Zsh"; exit 1; }

# 1. Remove zsh custom plugins
if command -v brew &>/dev/null; then
    brew remove \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        zsh-completions
else
    ZSH_PLUGIN_PREFIX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    rm -rf "${ZSH_PLUGIN_PREFIX}/zsh-completions"
    rm -rf "${ZSH_PLUGIN_PREFIX}/zsh-autosuggestions"
    rm -rf "${ZSH_PLUGIN_PREFIX}/zsh-syntax-highlighting"
fi

# 2. Remove shell profile for zsh custom plugins
if grep -q "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    grep -vF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "ZSH plugins config successfully removed from $SHELL_RC"
    source $SHELL_RC
else
    echo "No ZSH plugins config found in $SHELL_RC. No changes made."
    exit
fi

# 3. Remove oh-my-zsh by manual
echo "[OMZ] Not support to uninstall oh-my-zsh. Please enter the below command manually"
echo "uninstall_oh_my_zsh"