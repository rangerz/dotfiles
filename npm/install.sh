#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if ! type npm >/dev/null 2>&1; then
    echo "npm is not installed."
    echo "Please install npm first. Try 'brew install node'"
    exit
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

packages=()

read_file_to_array "$CUR_DIR/packages" packages

# Install packages from npm
[ ${#packages[@]} -ne 0 ] && npm -g install "${packages[@]}"

echo "[NPM] Installation completed."
