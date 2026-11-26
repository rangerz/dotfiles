#!/usr/bin/env bash
# Self-check for Codex hook installation and removal in a throwaway HOME.
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

CODEX_DIR="$TMP_HOME/.codex"
HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
HOOK_COMMAND="python3 \"$HOOK_SCRIPT\""

fail() {
    echo "[codex test] FAIL: $1" >&2
    exit 1
}

mkdir -p "$CODEX_DIR"
cat >"$HOOK_CONFIG" <<'EOF'
{
  "hooks": {
    "Stop": [
      {"hooks": [{"type": "command", "command": "echo custom"}]}
    ],
    "OtherEvent": [
      {"hooks": [{"type": "command", "command": "echo keep"}]}
    ]
  }
}
EOF

HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ -L "$HOOK_SCRIPT" ]] || fail "hook script was not symlinked"
[[ "$(readlink "$HOOK_SCRIPT")" == "$CUR_DIR/hooks/next_steps.py" ]] || fail "hook points to the wrong repo path"
[[ "$(jq -r --arg command "$HOOK_COMMAND" '[.hooks.Stop[].hooks[] | select(.command == $command)] | length' "$HOOK_CONFIG")" == 1 ]] || fail "hook command was not registered once"

HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(jq -r '[.hooks.Stop[].hooks[] | select(.command == "echo custom")] | length' "$HOOK_CONFIG")" == 1 ]] || fail "custom Stop hook was changed"
[[ "$(jq -r --arg command "$HOOK_COMMAND" '[.hooks.Stop[].hooks[] | select(.command == $command)] | length' "$HOOK_CONFIG")" == 1 ]] || fail "rerun duplicated the Codex hook"

HOME="$TMP_HOME" "$CUR_DIR/uninstall.sh" >/dev/null
[[ ! -e "$HOOK_SCRIPT" && ! -L "$HOOK_SCRIPT" ]] || fail "uninstall left the repo symlink"
[[ "$(jq -r '[.hooks.Stop[].hooks[] | select(.command == "echo custom")] | length' "$HOOK_CONFIG")" == 1 ]] || fail "uninstall removed the custom Stop hook"
[[ "$(jq -r '.hooks.OtherEvent[0].hooks[0].command' "$HOOK_CONFIG")" == "echo keep" ]] || fail "uninstall changed another event hook"

echo "[codex test] OK"
