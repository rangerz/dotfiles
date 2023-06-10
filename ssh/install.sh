#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
INCLUDE_CONFIG="Include $DIR/config"

mkdir -p "$HOME/.ssh/mux"

if ! grep -q "$INCLUDE_CONFIG" "$SSH_CONFIG"; then
    echo "$INCLUDE_CONFIG" >> "$SSH_CONFIG"
    echo "SSH configuration successfully updated."
else
    echo "Configuration line already exists in the file. No changes made."
fi
