#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"

[ ! -n "$ZSH_VERSION" ] || { echo "You are not using Zsh"; exit 1; }

# 1. Install oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 2. Install zsh plugins by brew
brew install \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-completions

# 3. Setup shell profile for brew zsh plugins
if ! grep -qF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    echo "$SOURCE_ZSH_PLUGINS" >> "$SHELL_RC"
    echo "Zsh plugins successfully updated into $SHELL_RC"
    source $SHELL_RC
else
    echo "Zsh plugins already exists in $SHELL_RC. No changes made."
fi

# TODO: fix me
# 4. Add build-in plugins setting
echo "[OMZ] Please manually add build-in plugins setting into ~/.zshrc"

echo "[OMZ] Installation completed."

