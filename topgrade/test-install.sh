#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's topgrade.d link, run against a throwaway HOME (no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

CONF_DIR="$TMP_HOME/.config/topgrade.d"
CONF_TOML="$CONF_DIR/dotfiles.toml"
BACKUP="$TMP_HOME/.config/topgrade-dotfiles.toml.bak"
REPO="$CUR_DIR/topgrade.toml"
fail() {
    echo "[topgrade test] FAIL: $1" >&2
    exit 1
}
# XDG_CONFIG_HOME is dropped so the throwaway HOME decides the path; output is shown on failure
run() {
    env -u XDG_CONFIG_HOME HOME="$TMP_HOME" "$CUR_DIR/$1" >"$TMP_HOME/out" 2>&1 ||
        {
            cat "$TMP_HOME/out" >&2
            fail "$1 exited non-zero"
        }
}
linked() { [[ -L "$CONF_TOML" && "$(readlink "$CONF_TOML")" == "$REPO" ]]; }

# Fresh HOME: the link is created, and a rerun keeps it without making a backup
run install.sh
run install.sh
linked || fail "install did not link $CONF_TOML to the repo file"
[[ ! -e "$BACKUP" ]] || fail "rerun backed up our own link"

# Uninstall removes the link and the now-empty topgrade.d
run uninstall.sh
[[ ! -e "$CONF_TOML" && ! -L "$CONF_TOML" ]] || fail "uninstall left $CONF_TOML"
[[ ! -d "$CONF_DIR" ]] || fail "uninstall left the empty $CONF_DIR"

# Nothing installed: uninstall is a no-op
run uninstall.sh

# A different real file is backed up outside topgrade.d, so topgrade does not load it
mkdir -p "$CONF_DIR"
printf '# user\n' >"$CONF_TOML"
run install.sh
linked || fail "install did not replace the user file with the link"
grep -qx '# user' "$BACKUP" || fail "install did not back up the user file"

# A real file identical to ours is replaced without a backup
rm -f "$BACKUP" "$CONF_TOML"
cp "$REPO" "$CONF_TOML"
run install.sh
linked || fail "install did not replace the identical copy with the link"
[[ ! -e "$BACKUP" ]] || fail "install backed up a copy identical to ours"

# Uninstall keeps other files in topgrade.d and the directory with them
printf '# other\n' >"$CONF_DIR/other.toml"
run uninstall.sh
[[ ! -L "$CONF_TOML" ]] || fail "uninstall left the link next to another file"
[[ -f "$CONF_DIR/other.toml" ]] || fail "uninstall removed another file in $CONF_DIR"

echo "[topgrade test] OK"
