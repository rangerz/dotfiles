#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
SOURCE_VIMRC="source $DOTFILES/vim/vimrc"
VIMRC_FILE="$HOME/.vimrc"
# Created by older installs; vimrc no longer uses them (nobackup, noswapfile, no undofile)
VIM_DIRS=("$HOME/.vim/.backup" "$HOME/.vim/.swp" "$HOME/.vim/.undo")

if grep -qxF "$SOURCE_VIMRC" "$VIMRC_FILE"; then
    # Fixed-string match: the line holds a path whose "/" breaks a sed address; `|| true` keeps an emptied file
    grep -vxF "$SOURCE_VIMRC" "$VIMRC_FILE" >"$VIMRC_FILE.tmp" || true
    # cat (not mv) keeps the original file's mode and any symlink
    cat "$VIMRC_FILE.tmp" >"$VIMRC_FILE"
    rm -f "$VIMRC_FILE.tmp"
    echo "Vim config successfully removed from $VIMRC_FILE"
else
    echo "No vim config found in $VIMRC_FILE. No changes made."
fi

for dir in "${VIM_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Removed directory: $dir"
    fi
done

echo "[VIM] Uninstallation completed."
