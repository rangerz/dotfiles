#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
SOURCE_VIMRC="source $DOTFILES/vim/vimrc"
VIMRC_FILE="$HOME/.vimrc"
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
