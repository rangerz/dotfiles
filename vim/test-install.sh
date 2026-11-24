#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's ~/.vimrc source line, run against a throwaway HOME (no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

VIMRC="$TMP_HOME/.vimrc"
# The installers point at ~/.dotfiles, not at this checkout
LINE="source $TMP_HOME/.dotfiles/vim/vimrc"
fail() {
    echo "[vim test] FAIL: $1" >&2
    exit 1
}
# Output is kept quiet but shown when an installer fails
run() { HOME="$TMP_HOME" "$CUR_DIR/$1" >"$TMP_HOME/out" 2>&1 || {
    cat "$TMP_HOME/out" >&2
    fail "$1 exited non-zero"
}; }
count() { grep -cxF "$LINE" "$VIMRC" || true; }

# Uninstall before any install: no ~/.vimrc, no error
run uninstall.sh
[[ ! -e "$VIMRC" ]] || fail "uninstall created ~/.vimrc"

# Install creates a missing ~/.vimrc with the line
run install.sh
[[ "$(count)" == 1 ]] || fail "install did not create ~/.vimrc with the source line"

# Appended after existing lines, once even on rerun
printf 'set number\n' >"$VIMRC"
run install.sh
run install.sh
[[ "$(count)" == 1 ]] || fail "expected the source line once, got $(count)"

# Uninstall drops only that line and the legacy dirs from older installs
mkdir -p "$TMP_HOME/.vim/.backup" "$TMP_HOME/.vim/.swp" "$TMP_HOME/.vim/.undo" "$TMP_HOME/.vim/keep"
run uninstall.sh
[[ "$(cat "$VIMRC")" == 'set number' ]] || fail "uninstall did not leave just the user lines"
for dir in .backup .swp .undo; do
    [[ ! -e "$TMP_HOME/.vim/$dir" ]] || fail "uninstall left ~/.vim/$dir"
done
[[ -d "$TMP_HOME/.vim/keep" ]] || fail "uninstall removed an unrelated ~/.vim dir"

# The legacy dirs go even when the source line is already gone
mkdir -p "$TMP_HOME/.vim/.backup"
run uninstall.sh
[[ ! -e "$TMP_HOME/.vim/.backup" ]] || fail "uninstall without the source line left ~/.vim/.backup"

# A commented-out copy of the line does not count as installed
printf '" %s\n' "$LINE" >"$VIMRC"
run install.sh
[[ "$(count)" == 1 ]] || fail "install skipped the line because of a commented-out copy"

echo "[vim test] OK"
