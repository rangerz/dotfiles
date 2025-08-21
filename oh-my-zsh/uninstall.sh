#!/bin/sh
set -eu

ZSH=${ZSH:-$HOME/.oh-my-zsh}
UNINSTALL="$ZSH/tools/uninstall.sh"

if [ ! -d "$ZSH" ]; then
    echo "oh-my-zsh is not installed"
    exit 0
fi

if [ ! -f "$UNINSTALL" ]; then
    echo "Not found: $UNINSTALL"
    exit 1
fi

sh "$UNINSTALL"
