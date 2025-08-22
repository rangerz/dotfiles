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

    # todo: support other shells
    # Install zsh and oh-my-zsh
    "$DOTFILES/zsh/install.sh"
    "$DOTFILES/oh-my-zsh/install.sh"

    # Install Homebrew and packages
    "$DOTFILES/brew/install.sh"
    source "$DOTFILES/brew/eval_brew.sh"

    # Set configs for shell + git + ssh + vim + mise
    "$DOTFILES/shell/install.sh"
    "$DOTFILES/git/install.sh"
    "$DOTFILES/ssh/install.sh"
    "$DOTFILES/vim/install.sh"
    "$DOTFILES/mise/install.sh"

    echo "Done. Dotfiles installed in $DOTFILES"
}

main "$@"
