#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ZSH_PLUGINS="$CUR_DIR/plugins.zsh"
SOURCE_ZSH_PLUGINS="source $ZSH_PLUGINS"
SHELL_RC="$HOME/.zshrc"

[ ! -n "$ZSH_VERSION" ] || { echo "You are not using Zsh"; exit 1; }

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install omz plugins from brew, may sure update source file in `plugins.zsh`
brew install \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-completions

# Check if the configuration already exists
if ! grep -qF "$SOURCE_ZSH_PLUGINS" "$SHELL_RC"; then
    echo "$SOURCE_ZSH_PLUGINS" >> "$SHELL_RC"
    echo "Zsh plugins successfully updated into $SHELL_RC"
else
    echo "Zsh plugins already exists in $SHELL_RC. No changes made."
    exit
fi

echo "[OMZ] Installation completed."

echo "[OMZ] Please manually add buildin plugins setting into ~/.zshrc"
exit

# TODO: Edit in ~/.zshrc for setting
# buildin plugins
plugins=(
  aws
  brew
  colored-man-pages
  colorize
  docker
  docker-compose
  extract
  pip
  python
  macos
  z
)
