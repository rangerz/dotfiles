#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's ~/.zshrc source line, run against a throwaway HOME (no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

ZSHRC="$TMP_HOME/.zshrc"
LINE="source $CUR_DIR/shell.sh"
fail() {
    echo "[shell test] FAIL: $1" >&2
    exit 1
}
# Output is kept quiet but shown when an installer fails
run() { HOME="$TMP_HOME" "$CUR_DIR/$1" >"$TMP_HOME/out" 2>&1 || {
    cat "$TMP_HOME/out" >&2
    fail "$1 exited non-zero"
}; }
count() { grep -cxF "$LINE" "$ZSHRC" || true; }

# No ~/.zshrc yet: install creates it with the line once, even on rerun
run install.sh
run install.sh
[[ "$(count)" == 1 ]] || fail "expected the source line once, got $(count)"

# Uninstall drops only that line and keeps a symlinked ~/.zshrc a symlink
printf 'alias keep=me\n' >"$TMP_HOME/real-zshrc"
ln -sf "$TMP_HOME/real-zshrc" "$ZSHRC"
run install.sh
run uninstall.sh
[[ -L "$ZSHRC" ]] || fail "uninstall replaced the ~/.zshrc symlink"
[[ "$(count)" == 0 ]] || fail "uninstall left the source line"
grep -qx 'alias keep=me' "$ZSHRC" || fail "uninstall lost user lines"

# Rerunning uninstall is a no-op
run uninstall.sh
[[ "$(cat "$ZSHRC")" == 'alias keep=me' ]] || fail "second uninstall changed ~/.zshrc"

# A commented-out copy of the line does not count as installed
printf '# %s\n' "$LINE" >"$ZSHRC"
run install.sh
[[ "$(count)" == 1 ]] || fail "install skipped the line because of a commented-out copy"

# Sourcing shell.sh in a bare interactive zsh prints nothing to stderr, perl included (catches a missing locale)
err="$(env -u HOMEBREW_PREFIX HOME="$TMP_HOME" zsh -fic "source '$CUR_DIR/shell.sh'; command -v perl >/dev/null && perl -e1" 2>&1 >/dev/null)" ||
    fail "sourcing shell.sh failed: $err"
[[ -z "$err" ]] || fail "sourcing shell.sh printed to stderr: $err"

# GNU ls: the fallback alias must not pass -G (--no-group there, not color)
if command ls --color=auto -d . >/dev/null 2>&1; then
    ls_alias="$(env -u HOMEBREW_PREFIX HOME="$TMP_HOME" PATH="/usr/bin:/bin" zsh -fic "source '$CUR_DIR/shell.sh'; alias ls" 2>/dev/null)"
    [[ "$ls_alias" != *-G* ]] || fail "GNU ls alias uses -G: $ls_alias"
fi

echo "[shell test] OK"
