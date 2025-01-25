#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# 1. Install mas
brew install mas

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

# 2. Install Mac App Store apps
mas_apps=()
read_file_to_array "$CUR_DIR/mas_apps" mas_apps
[ ${#mas_apps[@]} -ne 0 ] && mas install "${mas_apps[@]}"

echo "[MAS] Installation completed."
