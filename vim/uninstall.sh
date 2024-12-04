#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOT_VIMRC="$HOME/.vimrc"
SOURCE_VIMRC="source $CUR_DIR/vimrc"
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")

# Remove the configuration
if grep -q "$SOURCE_VIMRC" "$DOT_VIMRC"; then
    grep -vF "$SOURCE_VIMRC" "$DOT_VIMRC" > "$DOT_VIMRC.tmp" && mv "$DOT_VIMRC.tmp" "$DOT_VIMRC"
    echo "Vim config successfully removed from $DOT_VIMRC"
else
    echo "No vim config found in $DOT_VIMRC. No changes made."
    exit
fi

# Remove created directories
for dir in "${VIM_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Removed directory: $dir"
    fi
done

echo "[VIM] Uninstallation completed."