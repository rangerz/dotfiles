#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
VIMRC_FILE="$HOME/.vimrc"
SOURCE_VIMRC="source $CUR_DIR/vimrc"
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")

if grep -q "$SOURCE_VIMRC" "$VIMRC_FILE"; then
    sed -i'' -e "/$SOURCE_VIMRC/d" "$VIMRC_FILE"
    echo "Vim config successfully removed from $VIMRC_FILE"
else
    echo "No vim config found in $VIMRC_FILE. No changes made."
    exit
fi

for dir in "${VIM_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Removed directory: $dir"
    fi
done

echo "[VIM] Uninstallation completed."
