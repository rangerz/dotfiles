#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
MISE_PROFILE="$CUR_DIR/miseprofile"
SOURCE_PROFILE="source $MISE_PROFILE"
SHELL_RC="$HOME/.zshrc"

# 1. Install mise
if command -v brew &>/dev/null; then
    brew install mise
fi

if command -v apt &>/dev/null; then
    sudo apt update -y && sudo apt install -y gpg sudo wget curl
    sudo install -dm 755 /etc/apt/keyrings
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise
fi

# 2. Setup mise profile
if ! grep -qF "$SOURCE_PROFILE" "$SHELL_RC"; then
    echo "$SOURCE_PROFILE" >> "$SHELL_RC"
    echo "Shell config successfully updated into $SHELL_RC"
    source $SHELL_RC
else
    echo "Shell config already exists in $SHELL_RC. No changes made."
fi

# 3. Setup node and python
mise use -g node@lts python@3 rust

# 4. Install global node package
#npm install -g @shopify/cli@latest

echo "[mise] Installation completed."
