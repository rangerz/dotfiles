#!/usr/bin/env bash
# Self-check for install.sh's include.path and its Claude Code cloud guard,
# run on a copy of git/ inside a throwaway repo and HOME (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

# install.sh sets core.hooksPath on the repo around it, so give it a throwaway one
REPO="$TMP_HOME/repo"
git init -q "$REPO"
cp -R "$CUR_DIR" "$REPO/git"
GIT_CONFIG="$REPO/git/gitconfig"

fail() {
    echo "[git test] FAIL: $1" >&2
    exit 1
}
# Isolate from the host's global and system git config
gitc() { env -u GIT_CONFIG_GLOBAL HOME="$TMP_HOME" GIT_CONFIG_NOSYSTEM=1 git "$@"; }
run_install() { env -u GIT_CONFIG_GLOBAL HOME="$TMP_HOME" GIT_CONFIG_NOSYSTEM=1 "$@" "$REPO/git/install.sh" >/dev/null; }
includes() { gitc config --global --get-all include.path || true; }

# Cloud session: hook enabled, include.path skipped (it would override commit signing)
run_install env CLAUDE_CODE_REMOTE=true
[[ -z "$(includes)" ]] || fail "cloud install added include.path"
[[ "$(gitc -C "$REPO" config core.hooksPath)" == .githooks ]] || fail "cloud install did not enable .githooks"

# Elsewhere: include.path added once, even on rerun
run_install env -u CLAUDE_CODE_REMOTE
run_install env -u CLAUDE_CODE_REMOTE
[[ "$(includes)" == "$GIT_CONFIG" ]] || fail "expected include.path [$GIT_CONFIG] once, got [$(includes)]"

echo "[git test] OK"
