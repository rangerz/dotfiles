#!/usr/bin/env bash
# Self-check for Codex hook installation and removal in a throwaway HOME.
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

CODEX_DIR="$TMP_HOME/.codex"
HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.sh"
OLD_HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
HOOK_COMMAND="bash \"$HOOK_SCRIPT\""
MOCK_BIN="$TMP_HOME/mock-bin"
PLUGIN_LOG="$TMP_HOME/plugin.log"

fail() {
    echo "[codex test] FAIL: $1" >&2
    exit 1
}

MISSING_JQ_HOME="$TMP_HOME/missing-jq-home"
MISSING_JQ_BIN="$TMP_HOME/missing-jq-bin"
mkdir -p "$MISSING_JQ_BIN"
for command_name in dirname mkdir mv ln cp mktemp yq; do
    ln -s "$(command -v "$command_name")" "$MISSING_JQ_BIN/$command_name"
done
if PATH="$MISSING_JQ_BIN" HOME="$MISSING_JQ_HOME" /bin/bash "$CUR_DIR/install.sh" >"$TMP_HOME/missing-jq.log" 2>&1; then
    fail "install succeeded without jq"
fi
grep -qF 'jq is required to update hooks.json' "$TMP_HOME/missing-jq.log" || fail "missing jq error was not clear"
[[ ! -e "$MISSING_JQ_HOME/.codex" ]] || fail "install changed files before checking jq"

mkdir -p "$MOCK_BIN"
cat >"$MOCK_BIN/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
# Swallow stdin like an interactive prompt would; install.sh must not feed it the list files
cat >/dev/null
case "$*" in
    "plugin marketplace list --json")
        printf '{"marketplaces":[{"name":"ponytail"}]}\n'
        ;;
    "plugin marketplace add "*)
        printf 'marketplace %s\n' "${4:?}" >>"$PLUGIN_LOG"
        ;;
    "plugin list --json")
        printf '{"installed":[{"pluginId":"ponytail@ponytail"}]}\n'
        ;;
    "plugin add "*)
        printf '%s\n' "${3:?}" >>"$PLUGIN_LOG"
        ;;
    *)
        exit 1
        ;;
esac
EOF
chmod +x "$MOCK_BIN/codex"

mkdir -p "$CODEX_DIR"
mkdir -p "$CODEX_DIR/hooks"
ln -s "$CUR_DIR/hooks/next_steps_legacy.py" "$OLD_HOOK_SCRIPT"
cat >"$CODEX_DIR/config.toml" <<'EOF'
model = "gpt-5-codex"

[tui]
theme = "my-theme"
status_line = [
    "old-model",
]
status_line_use_colors = true
EOF
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

PATH="$MOCK_BIN:$PATH" PLUGIN_LOG="$PLUGIN_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >"$TMP_HOME/install.log"
grep -qF '[codex] Marketplace ponytail already added.' "$TMP_HOME/install.log" || fail "added marketplace was not skipped"
grep -qF '[codex] Plugin ponytail@ponytail already installed.' "$TMP_HOME/install.log" || fail "installed plugin was not skipped"
[[ "$(cat "$PLUGIN_LOG")" == $'marketplace https://github.com/GoogleChrome/modern-web-guidance.git\nmodern-web-guidance@googlechrome\nshopify@openai-curated' ]] || fail "marketplaces and plugins were not installed in order"
[[ -L "$HOOK_SCRIPT" ]] || fail "hook script was not symlinked"
[[ "$(readlink "$HOOK_SCRIPT")" == "$CUR_DIR/hooks/next_steps.sh" ]] || fail "hook points to the wrong repo path"
[[ ! -e "$OLD_HOOK_SCRIPT" && ! -L "$OLD_HOOK_SCRIPT" ]] || fail "install left the obsolete hook symlink"
[[ "$(jq -r --arg command "$HOOK_COMMAND" '[.hooks.Stop[].hooks[] | select(.command == $command)] | length' "$HOOK_CONFIG")" == 1 ]] || fail "hook command was not registered once"
grep -qF 'model = "gpt-5-codex"' "$CODEX_DIR/config.toml" || fail "existing Codex config was changed"
grep -qF 'theme = "my-theme"' "$CODEX_DIR/config.toml" || fail "existing TUI config was changed"
grep -qF '"model-with-reasoning"' "$CODEX_DIR/config.toml" || fail "status line was not installed"
grep -qF '"five-hour-limit"' "$CODEX_DIR/config.toml" || fail "status line config was not copied"
[[ "$(yq -p toml -o json '.tui.status_line_use_colors' "$CODEX_DIR/config.toml")" == true ]] || fail "following TUI setting was changed"

PATH="$MOCK_BIN:$PATH" PLUGIN_LOG="$PLUGIN_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(jq -r '[.hooks.Stop[].hooks[] | select(.command == "echo custom")] | length' "$HOOK_CONFIG")" == 1 ]] || fail "custom Stop hook was changed"
[[ "$(jq -r --arg command "$HOOK_COMMAND" '[.hooks.Stop[].hooks[] | select(.command == $command)] | length' "$HOOK_CONFIG")" == 1 ]] || fail "rerun duplicated the Codex hook"
[[ "$(grep -c '^status_line =' "$CODEX_DIR/config.toml")" == 1 ]] || fail "rerun duplicated status line"
yq -p toml -o json '.' "$CODEX_DIR/config.toml" >/dev/null || fail "resulting Codex TOML is invalid"
hook_output="$(printf '%s' '{"last_assistant_message":"Done"}' | bash "$HOOK_SCRIPT")"
[[ "$(jq -r '.decision' <<<"$hook_output")" == block ]] || fail "hook did not block for a review"
hook_output="$(printf '%s' '{"last_assistant_message":"Done\n\nNext steps:"}' | bash "$HOOK_SCRIPT")"
[[ -z "$hook_output" ]] || fail "hook blocked an answer that already has next steps"
hook_output="$(printf '%s' '{"stop_hook_active":true,"last_assistant_message":"Done"}' | bash "$HOOK_SCRIPT")"
[[ -z "$hook_output" ]] || fail "hook continued an already-continued turn"

ln -s "$CUR_DIR/hooks/next_steps_legacy.py" "$OLD_HOOK_SCRIPT"
HOME="$TMP_HOME" "$CUR_DIR/uninstall.sh" >/dev/null
[[ ! -e "$HOOK_SCRIPT" && ! -L "$HOOK_SCRIPT" ]] || fail "uninstall left the repo symlink"
[[ ! -e "$OLD_HOOK_SCRIPT" && ! -L "$OLD_HOOK_SCRIPT" ]] || fail "uninstall left the obsolete hook symlink"
[[ "$(jq -r '[.hooks.Stop[].hooks[] | select(.command == "echo custom")] | length' "$HOOK_CONFIG")" == 1 ]] || fail "uninstall removed the custom Stop hook"
[[ "$(jq -r '.hooks.OtherEvent[0].hooks[0].command' "$HOOK_CONFIG")" == "echo keep" ]] || fail "uninstall changed another event hook"

echo "[codex test] OK"
