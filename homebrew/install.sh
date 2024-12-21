#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if command -v brew &> /dev/null; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

read_file_to_array() {
    local file="$1"
    local array_name="$2"

    eval "$array_name=()"

    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')
        if [[ -n "$line" ]]; then
            eval "$array_name+=('$line')"
        fi
    done < "$file"
}

formulae=()
casks=()

# Other option is using `brew bundle` with Brewfile
read_file_to_array "$CUR_DIR/formulae" formulae
read_file_to_array "$CUR_DIR/casks" casks

# Install homebrew packages, casks, and mac apps from App Store
[ ${#formulae[@]} -ne 0 ] && brew install "${formulae[@]}"
[ ${#casks[@]} -ne 0 ] && brew install --cask "${casks[@]}"

brew cleanup

echo "[Brew] Installation completed."
