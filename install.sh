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
        # Already cloned: update, then continue so the remaining steps re-run
        # 已經 clone 過:更新後繼續執行後續步驟(不可 exit,否則重跑會被跳過)
        echo "Dotfiles already installed at $DOTFILES, updating"
        git -C "$DOTFILES" pull --ff-only || echo "Update skipped (local changes or no network), continuing"
        return 0
    fi

    echo "Cloning dotfiles into $DOTFILES"
    git clone --depth=1 --single-branch --branch "$BRANCH" "$REMOTE" "$DOTFILES"
}

# Install order matters: brew provides the tools that the later modules use
MODULES="wsl zsh oh-my-zsh brew shell git ssh vim mise topgrade claude codex"

usage() {
    echo "Usage: install.sh [--only <module>[,<module>...]]"
    echo "Modules: $MODULES"
}

# Keep MODULES order, whatever order --only lists them in
select_modules() {
    # Split on commas and spaces once, so validation and selection see the same names
    list=" $(echo "$1" | tr ',' ' ' | tr -s ' ') "
    selected=""
    for want in $list; do
        case " $MODULES " in
        *" $want "*) ;;
        *)
            echo "Unknown module: $want"
            usage
            exit 1
            ;;
        esac
    done
    for mod in $MODULES; do
        case "$list" in
        *" $mod "*) selected="$selected $mod" ;;
        esac
    done
    echo "$selected"
}

run_module() {
    case "$1" in
    # WSL-only utilities (no-op outside WSL); failure must not block core setup
    # WSL 專屬工具(非 WSL 時為 no-op);失敗不應中斷後續核心安裝
    wsl) "$DOTFILES/wsl/install.sh" || echo "WSL setup skipped/failed, continuing" ;;
    codex) "$DOTFILES/agents/codex/install.sh" ;;
    claude) "$DOTFILES/agents/claude/install.sh" ;;
    *) "$DOTFILES/$1/install.sh" ;;
    esac
}

main() {
    modules="$MODULES"
    case "${1:-}" in
    "") ;;
    --only)
        # Extra arguments usually mean a space instead of a comma: "--only git claude"
        if [ -z "${2:-}" ] || [ $# -gt 2 ]; then
            usage
            exit 1
        fi
        modules="$(select_modules "$2")" || {
            echo "$modules"
            exit 1
        }
        if [ -z "$modules" ]; then
            usage
            exit 1
        fi
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
    esac

    echo "Installing dotfiles into $DOTFILES"

    download_dotfiles

    for mod in $modules; do
        run_module "$mod"
    done

    echo "Done. Dotfiles installed in $DOTFILES"

    # Only a full install switches to zsh; a partial one may not have installed it
    if [ -z "${1:-}" ]; then
        exec zsh -l
    fi
}

main "$@"
