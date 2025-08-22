#!/bin/sh

set -eu

DOTFILES="$HOME/.dotfiles"

uninstall_confirm() {
    read -r -p "Are you sure you want to remove dotfiles? [y/N] " confirmation
    if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
        echo "Uninstall cancelled"
        exit
    fi
}

remove_dotfiles() {
    if [ ! -d "$DOTFILES" ]; then
        echo "Dotfiles not found at $DOTFILES"
        exit 0
    fi

    echo "Removing dotfiles from $DOTFILES"
    rm -rf "$DOTFILES"
}

main() {
    uninstall_confirm

    echo "Uninstalling dotfiles from $DOTFILES"

    "$DOTFILES/shell/uninstall.sh"
    "$DOTFILES/git/uninstall.sh"
    "$DOTFILES/ssh/uninstall.sh"
    "$DOTFILES/vim/uninstall.sh"
    "$DOTFILES/mise/uninstall.sh"

    "$DOTFILES/brew/uninstall.sh"

    remove_dotfiles

    echo "Done. Dotfiles removed from $DOTFILES"
}

#main "$@"

echo "Not supported yet"
