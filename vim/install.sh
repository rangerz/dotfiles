#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOT_VIMRC="$HOME/.vimrc"
SOURCE_VIMRC="source $CUR_DIR/vimrc"
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")

# Ensure the .vimrc file exists
if [ ! -f "$DOT_VIMRC" ]; then
    touch "$DOT_VIMRC"
    echo "Created $DOT_VIMRC"
fi

# Check if the configuration already exists
if ! grep -qF "$SOURCE_VIMRC" "$DOT_VIMRC"; then
    echo "$SOURCE_VIMRC" >> "$DOT_VIMRC"
    echo "Vim config successfully updated into $DOT_VIMRC"
else
    echo "Vim config already exists in $DOT_VIMRC. No changes made."
    exit
fi

# Create necessary directories
for dir in "${VIM_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    fi
done

echo "[VIM] Installation completed."