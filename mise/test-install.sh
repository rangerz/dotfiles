#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's config link, run against a throwaway HOME with a stub mise (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

# A stub mise that records each call, so `mise install` stays offline
mkdir -p "$TMP_HOME/bin"
printf '#!/bin/sh\necho "$*" >>"%s/mise.log"\n' "$TMP_HOME" >"$TMP_HOME/bin/mise"
chmod +x "$TMP_HOME/bin/mise"

TARGET="$TMP_HOME/.config/mise/config.toml"
REPO="$CUR_DIR/config.toml"
fail() {
    echo "[mise test] FAIL: $1" >&2
    exit 1
}
# Output is shown on failure
run() {
    env HOME="$TMP_HOME" PATH="$TMP_HOME/bin:$PATH" "$CUR_DIR/$1" >"$TMP_HOME/out" 2>&1 ||
        {
            cat "$TMP_HOME/out" >&2
            fail "$1 exited non-zero"
        }
}
linked() { [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$REPO" ]]; }

# Fresh HOME: the config is linked and `mise install` runs; a rerun makes no backup
run install.sh
run install.sh
linked || fail "install did not link $TARGET to the repo file"
[[ ! -e "$TARGET.bak" ]] || fail "rerun backed up our own link"
[[ "$(grep -cx 'install' "$TMP_HOME/mise.log")" == 2 ]] || fail "install did not run mise install each time"

# Uninstall without an earlier config leaves a real copy, so installed tools stay active
run uninstall.sh
[[ -f "$TARGET" && ! -L "$TARGET" ]] || fail "uninstall did not replace the link with a copy"
cmp -s "$TARGET" "$REPO" || fail "uninstall copy differs from the repo file"

# An existing real config is backed up on install and restored on uninstall
printf '# user\n' >"$TARGET"
run install.sh
linked || fail "install did not replace the user config with the link"
grep -qx '# user' "$TARGET.bak" || fail "install did not back up the user config"
run uninstall.sh
[[ ! -L "$TARGET" ]] || fail "uninstall left the link"
grep -qx '# user' "$TARGET" || fail "uninstall did not restore the user config"
[[ ! -e "$TARGET.bak" ]] || fail "uninstall left the backup behind"

# A config that is not our link is left alone by uninstall
run uninstall.sh
grep -qx '# user' "$TARGET" || fail "uninstall touched a config it did not link"

# A link to another config is backed up on install and restored on uninstall
rm "$TARGET"
ln -s "$TMP_HOME/other.toml" "$TARGET"
run install.sh
linked || fail "install did not replace the other link with ours"
[[ "$(readlink "$TARGET.bak")" == "$TMP_HOME/other.toml" ]] || fail "install did not back up the other link"
run uninstall.sh
[[ "$(readlink "$TARGET")" == "$TMP_HOME/other.toml" ]] || fail "uninstall did not restore the other link"

echo "[mise test] OK"
