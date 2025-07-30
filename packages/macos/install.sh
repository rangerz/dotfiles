#!/usr/bin/env zsh

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

[[ "$(uname)" == "Darwin" ]] || { echo "[Brew] Not macOS. Skipping brew install."; exit 0; }

if command -v brew &> /dev/null; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --file "$CUR_DIR/Brewfile"

brew cleanup

echo "[Brew] Installation completed."
