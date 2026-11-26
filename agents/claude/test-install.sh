#!/usr/bin/env bash
# Self-check for install.sh's settings.json merge and CLAUDE.md link, run against a throwaway HOME (no network, no real files touched)
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
  "localOnly": true
}
EOF
chmod 600 "$SETTINGS"
run_install
cp "$SETTINGS" "$TMP_HOME/first"
run_install

# Merging the repo file again changes nothing only if every repo value is already applied
[[ "$(jq -s '.[0] * .[1] == .[0]' "$SETTINGS" "$REPO")" == true ]] || fail "repo values not applied"
[[ "$(key .permissions.allow)" == '["Bash(ls)"]' ]] || fail "lost local permissions.allow (shallow merge?)"
[[ "$(key .localOnly)" == true ]] || fail "lost local-only key"
cmp -s "$SETTINGS" "$TMP_HOME/first" || fail "rerun changed settings.json"
[[ -n "$(find "$SETTINGS" -perm 644)" ]] || fail "settings.json is not 0644"
compgen -G "$SETTINGS.*" >/dev/null && fail "temp file left behind"

# Invalid local JSON: left untouched and install still succeeds
echo '{oops' >"$SETTINGS"
run_install || fail "install failed on invalid settings.json"
[[ "$(cat "$SETTINGS")" == '{oops' ]] || fail "invalid settings.json was modified"

# CLAUDE.md: a link to somewhere else is backed up, our own link is not, on rerun
CLAUDE_MD="$TMP_HOME/.claude/CLAUDE.md"
rm -f "$CLAUDE_MD" "$CLAUDE_MD.bak"
ln -s "$TMP_HOME/other.md" "$CLAUDE_MD"
run_install
run_install
[[ "$(readlink "$CLAUDE_MD")" == "$CUR_DIR/CLAUDE.md" ]] || fail "install did not link CLAUDE.md to the repo"
[[ "$(readlink "$CLAUDE_MD.bak")" == "$TMP_HOME/other.md" ]] || fail "install did not back up the other CLAUDE.md link"

echo "[claude test] OK"
