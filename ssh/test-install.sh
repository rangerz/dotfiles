#!/usr/bin/env bash
# Self-check for install.sh/uninstall.sh's ~/.ssh setup, run against a throwaway HOME (no keys generated, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

SSH_DIR="$TMP_HOME/.ssh"
CONFIG="$SSH_DIR/config"
LINE="Include $CUR_DIR/config"
fail() {
    echo "[ssh test] FAIL: $1" >&2
    exit 1
}
# No TTY on stdin, so ssh-keygen.sh skips key generation; stderr is kept for the signing warning.
# ZDOTDIR is dropped so the zsh in ssh-keygen.sh does not read the real ~/.zshenv; output is shown on failure.
run() {
    env -u ZDOTDIR HOME="$TMP_HOME" "$CUR_DIR/$1" </dev/null >"$TMP_HOME/out" 2>"$TMP_HOME/stderr" ||
        {
            cat "$TMP_HOME/out" "$TMP_HOME/stderr" >&2
            fail "$1 exited non-zero"
        }
}
count() { grep -cxF "$LINE" "$CONFIG" || true; }
# shellcheck disable=SC2012 # ls -ld prints the same mode column on GNU and BSD, unlike stat
mode() { ls -ld "$1" | cut -c1-10; }

# Fresh HOME: ~/.ssh and ~/.ssh/mux are created 700, the Include line added once even on rerun
run install.sh
run install.sh
[[ "$(mode "$SSH_DIR")" == drwx------ ]] || fail ".ssh mode is $(mode "$SSH_DIR")"
[[ "$(mode "$SSH_DIR/mux")" == drwx------ ]] || fail ".ssh/mux mode is $(mode "$SSH_DIR/mux")"
[[ "$(count)" == 1 ]] || fail "expected the Include line once, got $(count)"
[[ ! -e "$SSH_DIR/id_ed25519" ]] || fail "install generated a key without a TTY"

# Warns while the signing key is missing, and stops once it exists
grep -q 'WARNING' "$TMP_HOME/stderr" || fail "no warning about the missing id_ed25519.pub"
touch "$SSH_DIR/id_ed25519.pub"
run install.sh
! grep -q 'WARNING' "$TMP_HOME/stderr" || fail "warned although id_ed25519.pub exists"

# Uninstall drops only the Include line and ~/.ssh/mux, keeping user config and keys
printf 'Host keep\n' >>"$CONFIG"
run uninstall.sh
[[ "$(count)" == 0 ]] || fail "uninstall left the Include line"
grep -qx 'Host keep' "$CONFIG" || fail "uninstall lost user config"
[[ ! -e "$SSH_DIR/mux" ]] || fail "uninstall left ~/.ssh/mux"
[[ -f "$SSH_DIR/id_ed25519.pub" ]] || fail "uninstall removed the key"

echo "[ssh test] OK"
