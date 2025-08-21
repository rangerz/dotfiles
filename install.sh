#!/bin/sh

set -eu

DOTFILES="$HOME/.dotfiles"
REMOTE="https://github.com/rangerz/dotfiles.git"
BRANCH="main"

download_dotfiles() {
    if ! command -v git >/dev/null 2>&1; then
        echo "git is not installed"
        exit 1
    fi

    if [ -d "$DOTFILES/.git" ]; then
        echo "Dotfiles already installed at $DOTFILES"
        exit 0
    fi

    echo "Cloning dotfiles into $DOTFILES"
    git clone --depth=1 --single-branch --branch "$BRANCH" "$REMOTE" "$DOTFILES"
}

main() {
    echo "Installing dotfiles into $DOTFILES"

    download_dotfiles

    echo "Done. Dotfiles installed in $DOTFILES"
}

main "$@"
