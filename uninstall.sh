#!/bin/sh

set -eu

DOTFILES="$HOME/.dotfiles"

# rm -rf below would destroy local work, so refuse while any exists
ensure_no_local_work() {
    if [ -n "$(git -C "$DOTFILES" status --porcelain 2>/dev/null)" ] ||
        [ -n "$(git -C "$DOTFILES" log --oneline '@{u}..' 2>/dev/null)" ]; then
        echo "$DOTFILES has uncommitted or unpushed changes; commit and push them first"
        exit 1
    fi
}

uninstall_confirm() {
    printf "Are you sure you want to remove dotfiles? [y/N] "
    read -r confirmation
    if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
        echo "Uninstall cancelled"
        exit
    fi
}

remove_dotfiles() {
    echo "Removing dotfiles from $DOTFILES"
    rm -rf "$DOTFILES"
}

main() {
    if [ ! -d "$DOTFILES" ]; then
        echo "Dotfiles not found at $DOTFILES"
        exit 0
    fi

    ensure_no_local_work
    uninstall_confirm

    echo "Uninstalling dotfiles from $DOTFILES"

    "$DOTFILES/shell/uninstall.sh"
    "$DOTFILES/git/uninstall.sh"
    "$DOTFILES/ssh/uninstall.sh"
    "$DOTFILES/vim/uninstall.sh"
    "$DOTFILES/mise/uninstall.sh"
    "$DOTFILES/topgrade/uninstall.sh"
    "$DOTFILES/claude/uninstall.sh"

    "$DOTFILES/brew/uninstall.sh"

    remove_dotfiles

    echo "Done. Dotfiles removed from $DOTFILES"
}

main "$@"
