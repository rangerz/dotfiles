#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

[[ "$(uname)" == "Darwin" ]] || { echo "Support MacOS only."; exit 0; }

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
        eval "$array_name+=('$line')"
    done < "$file"
}

formulae=()
casks=()

read_file_to_array "$CUR_DIR/formulae" formulae
read_file_to_array "$CUR_DIR/casks" casks

# Install packages and casks
brew install "${formulae[@]}"
brew install --cask "${casks[@]}"

brew cleanup
