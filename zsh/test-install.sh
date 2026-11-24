#!/usr/bin/env bash
# Self-check for install.sh's default-shell setup, run with stubbed zsh/chsh/sudo in a throwaway HOME
# (nothing installed, /etc/shells and the login shell untouched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

BIN="$TMP_HOME/bin"
LOG="$TMP_HOME/calls"
ZSHRC="$TMP_HOME/.zshrc"
mkdir "$BIN"
: >"$LOG"
# Each stub records its call; sudo swallows stdin so `sudo tee -a /etc/shells` writes nothing
for cmd in zsh chsh sudo; do
    printf '#!/bin/sh\necho "%s $*" >>"%s"\n[ %s = sudo ] && cat >/dev/null\nexit 0\n' "$cmd" "$LOG" "$cmd" >"$BIN/$cmd"
    chmod +x "$BIN/$cmd"
done

run_install() { env -u ZDOTDIR HOME="$TMP_HOME" PATH="$BIN:$PATH" SHELL="$1" "$CUR_DIR/install.sh" </dev/null >/dev/null; }
fail() {
    echo "[zsh test] FAIL: $1" >&2
    exit 1
}

# Already the default shell: nothing is called or created
run_install "$BIN/zsh"
[[ ! -s "$LOG" ]] || fail "fast path called: $(cat "$LOG")"
[[ ! -e "$ZSHRC" ]] || fail "fast path created ~/.zshrc"

# Another login shell: zsh is added to /etc/shells, chsh runs without sudo, a minimal ~/.zshrc is created
run_install /bin/bash
grep -qxF "sudo tee -a /etc/shells" "$LOG" || fail "zsh was not added to /etc/shells"
grep -qxF "chsh -s $BIN/zsh" "$LOG" || fail "chsh was not called with the zsh path"
! grep -q '^sudo chsh' "$LOG" || fail "chsh ran under sudo (would change root's shell)"
grep -q 'compinit' "$ZSHRC" || fail "no minimal ~/.zshrc"

# Rerun keeps an existing ~/.zshrc as is
cp "$ZSHRC" "$TMP_HOME/first"
run_install /bin/bash
cmp -s "$ZSHRC" "$TMP_HOME/first" || fail "rerun changed ~/.zshrc"

echo "[zsh test] OK"
