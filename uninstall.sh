#!/bin/sh

set -eu

DOTFILES="$HOME/.dotfiles"

# rm -rf below would destroy local work, so refuse while any exists
ensure_no_local_work() {
    # --branches --not --remotes: commits on any local branch, with or without an upstream, that no remote has
    if [ -n "$(git -C "$DOTFILES" status --porcelain 2>/dev/null)" ] ||
        [ -n "$(git -C "$DOTFILES" log --oneline --branches --not --remotes 2>/dev/null)" ] ||
        [ -n "$(git -C "$DOTFILES" stash list 2>/dev/null)" ]; then
        echo "$DOTFILES has uncommitted, unpushed or stashed changes; commit and push them first"
        exit 1
    fi
}

uninstall_confirm() {
    echo "This also runs oh-my-zsh's own uninstaller, which asks again. If you answer y there,"
    echo "$HOME/.zshrc is renamed to $HOME/.zshrc.omz-uninstalled-<date> and $HOME/.zshrc.pre-oh-my-zsh is restored."
    echo "If you answer n, $HOME/.oh-my-zsh stays but its plugins block in $HOME/.zshrc points into the removed $DOTFILES."
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
    "$DOTFILES/agents/claude/uninstall.sh"
    "$DOTFILES/agents/codex/uninstall.sh"

    # Runs after shell/uninstall.sh: it renames ~/.zshrc and restores the pre-oh-my-zsh one
    "$DOTFILES/oh-my-zsh/uninstall.sh" || echo "oh-my-zsh uninstall failed, continuing"

    # These only print manual steps
    "$DOTFILES/zsh/uninstall.sh"
    "$DOTFILES/wsl/uninstall.sh"
    "$DOTFILES/brew/uninstall.sh"

    remove_dotfiles

    echo "Done. Dotfiles removed from $DOTFILES"
}

main "$@"
