#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's ~/.zshrc source line, run against a throwaway HOME (no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

ZSHRC="$TMP_HOME/.zshrc"
LINE="source $CUR_DIR/shell.sh"
# stderr dropped: grep reports the missing rc file on the first run
run() { HOME="$TMP_HOME" "$CUR_DIR/$1" >/dev/null 2>&1; }
count() { grep -cxF "$LINE" "$ZSHRC" || true; }
fail() {
    echo "[shell test] FAIL: $1" >&2
    exit 1
}

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

echo "[shell test] OK"
