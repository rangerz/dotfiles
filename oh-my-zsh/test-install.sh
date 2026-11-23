#!/usr/bin/env bash
# Self-check for install.sh's ~/.zshrc rewrite, run against a throwaway HOME (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

# install.sh reads plugins.sh from ~/.dotfiles and skips the network install when ~/.oh-my-zsh exists
ln -s "$CUR_DIR/.." "$TMP_HOME/.dotfiles"
mkdir "$TMP_HOME/.oh-my-zsh"

ZSHRC="$TMP_HOME/.zshrc"
run_install() { HOME="$TMP_HOME" zsh "$CUR_DIR/install.sh" >/dev/null; }
fail() {
    echo "[oh-my-zsh test] FAIL: $1" >&2
    exit 1
}

# An existing multi-line plugins block, with user lines before and after the source line
cat >"$ZSHRC" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
)
source $ZSH/oh-my-zsh.sh
alias keep=me
EOF
cp "$ZSHRC" "$TMP_HOME/original"

run_install
cp "$ZSHRC" "$TMP_HOME/first"
run_install
run_install

[[ "$(grep -c '^plugins=(' "$ZSHRC")" == 1 ]] || fail "expected exactly one plugins block"
[[ "$(grep -c 'copied into ~/.zshrc by install.sh' "$ZSHRC")" == 1 ]] || fail "shellcheck header repeated"
cmp -s "$ZSHRC" "$TMP_HOME/first" || fail "rerun changed ~/.zshrc"
cmp -s "$ZSHRC.bak" "$TMP_HOME/original" || fail ".zshrc.bak is not the original"
grep -qx 'alias keep=me' "$ZSHRC" || fail "lost user lines after the source line"
[[ "$(grep -n '^plugins=(' "$ZSHRC" | cut -d: -f1)" -lt "$(grep -n '^source .ZSH/oh-my-zsh.sh' "$ZSHRC" | cut -d: -f1)" ]] ||
    fail "plugins block is not before the source line"

echo "[oh-my-zsh test] OK"
