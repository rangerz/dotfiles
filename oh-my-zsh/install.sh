#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"
OMZ_PLUGINS_TXT="$CUR_DIR/omz_plugins.txt"

#[ ! -n "$ZSH_VERSION" ] || { echo "You are not using Zsh"; exit 1; }

# 1. Install oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 2. Install zsh custom plugins
if command -v brew &>/dev/null; then
    brew install \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        zsh-completions
else
    ZSH_PLUGIN_PREFIX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    [ -d "${ZSH_PLUGIN_PREFIX}/zsh-completions" ] || \
        git clone https://github.com/zsh-users/zsh-completions.git "${ZSH_PLUGIN_PREFIX}/zsh-completions"
    [ -d "${ZSH_PLUGIN_PREFIX}/zsh-autosuggestions" ] || \
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_PLUGIN_PREFIX}/zsh-autosuggestions"
    [ -d "${ZSH_PLUGIN_PREFIX}/zsh-syntax-highlighting" ] || \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_PLUGIN_PREFIX}/zsh-syntax-highlighting"
fi

# 3. Setup shell profile for zsh custom plugins
if ! grep -qF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    echo "$SOURCE_ZSH_PLUGINS" >> "$SHELL_RC"
    echo "ZSH plugins successfully updated into $SHELL_RC"
    source $SHELL_RC
else
    echo "ZSH plugins already exists in $SHELL_RC. No changes made."
fi

# 4. Add build-in plugins setting
echo "[OMZ] Please manually add build-in plugins setting into ~/.zshrc\n"
cat "$OMZ_PLUGINS_TXT"

echo "[OMZ] Installation completed."
echo "[OMZ] Please restart your terminal or run 'source ~/.zshrc'"
