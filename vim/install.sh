#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
SOURCE_VIMRC="source $DOTFILES/vim/vimrc"
VIMRC_FILE="$HOME/.vimrc"
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")

if [ ! -f "$VIMRC_FILE" ]; then
    touch "$VIMRC_FILE"
    echo "Created $VIMRC_FILE"
fi

if ! grep -qF "$SOURCE_VIMRC" "$VIMRC_FILE"; then
    echo "$SOURCE_VIMRC" >>"$VIMRC_FILE"
    echo "Vim config successfully updated into $VIMRC_FILE"
else
    echo "Vim config already exists in $VIMRC_FILE. No changes made."
    exit
fi

for dir in "${VIM_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    fi
done

echo "[VIM] Installation completed."
