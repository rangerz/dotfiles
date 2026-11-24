#!/usr/bin/env bash
# Self-check for install.sh's settings.json merge, run against a throwaway HOME (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

# A stub claude that reports nothing installed and accepts every command, so the plugin/MCP loops stay offline
mkdir -p "$TMP_HOME/bin" "$TMP_HOME/.claude"
printf '#!/bin/sh\necho "[]"\n' >"$TMP_HOME/bin/claude"
chmod +x "$TMP_HOME/bin/claude"

SETTINGS="$TMP_HOME/.claude/settings.json"
REPO="$CUR_DIR/settings.json"
run_install() { env -u XDG_CONFIG_HOME HOME="$TMP_HOME" PATH="$TMP_HOME/bin:$PATH" "$CUR_DIR/install.sh" >/dev/null 2>&1; }
fail() {
    echo "[claude test] FAIL: $1" >&2
    exit 1
}
key() { jq -c "$1" "$SETTINGS"; }

# Fresh machine: no settings.json yet
run_install
[[ "$(jq -S . "$SETTINGS")" == "$(jq -S . "$REPO")" ]] || fail "fresh install does not match the repo file"

# Existing settings with local-only keys and a value the repo overrides
cat >"$SETTINGS" <<'EOF'
{
  "model": "local-model",
  "permissions": { "defaultMode": "local-mode", "allow": ["Bash(ls)"] },
  "hooks": { "Stop": [] }
}
EOF
chmod 600 "$SETTINGS"
run_install
cp "$SETTINGS" "$TMP_HOME/first"
run_install

[[ "$(key .model)" == "$(jq -c .model "$REPO")" ]] || fail "repo value did not overwrite local value"
[[ "$(key .permissions.defaultMode)" == "$(jq -c .permissions.defaultMode "$REPO")" ]] || fail "nested repo value not applied"
[[ "$(key .permissions.allow)" == '["Bash(ls)"]' ]] || fail "lost local permissions.allow (shallow merge?)"
[[ "$(key .hooks)" == '{"Stop":[]}' ]] || fail "lost local-only key"
cmp -s "$SETTINGS" "$TMP_HOME/first" || fail "rerun changed settings.json"
[[ -n "$(find "$SETTINGS" -perm 644)" ]] || fail "settings.json is not 0644"
compgen -G "$SETTINGS.*" >/dev/null && fail "temp file left behind"

# Invalid local JSON: left untouched and install still succeeds
echo '{oops' >"$SETTINGS"
run_install || fail "install failed on invalid settings.json"
[[ "$(cat "$SETTINGS")" == '{oops' ]] || fail "invalid settings.json was modified"

echo "[claude test] OK"
