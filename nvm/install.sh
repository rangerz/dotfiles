#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/nvmprofile"
SOURCE_PROFILE="source $SHELL_PROFILE"
SHELL_RC="$HOME/.zshrc"

# 0. Remove nodejs (npm)
"$CUR_DIR/remove_brew_node.sh"

# 1. Install NVM
brew install nvm

# 2. Create NVM's working directory
mkdir -p ~/.nvm

# 3. Setup shell profile
if ! grep -qF "$SOURCE_PROFILE" "$SHELL_RC"; then
    echo "$SOURCE_PROFILE" >> "$SHELL_RC"
    echo "NVM config successfully updated into $SHELL_RC"
    #source $SHELL_RC
else
    echo "NVM config already exists in $SHELL_RC. No changes made."
fi

# 4. Install latest LTS node version
$SOURCE_PROFILE
nvm install node --lts --default

# 5. Install node packages
npm install --global yarn

echo "[NVM] Installation completed."
