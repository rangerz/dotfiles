#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOT_VIMRC="$HOME/.vimrc"
INCLUDE_VIMRC="source $DIR/vimrc"

mkdir -p ~/.vim/.backup
mkdir -p ~/.vim/.swp
mkdir -p ~/.vim/.undo

if ! grep -q "$INCLUDE_VIMRC" "$DOT_VIMRC"; then
    echo "$INCLUDE_VIMRC" >> "$DOT_VIMRC"
    echo "Vim config successfully updated."
else
    echo "Vim config already exists in $DOT_VIMRC. No changes made."
fi
