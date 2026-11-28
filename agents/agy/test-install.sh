#!/usr/bin/env bash
# Self-check for agy installation and removal in a throwaway HOME.
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

GEMINI_MD="$TMP_HOME/.gemini/GEMINI.md"
GLOBAL_SRC="$(cd "$CUR_DIR/.." && pwd)/global.md"
MOCK_BIN="$TMP_HOME/mock-bin"
AGY_LOG="$TMP_HOME/agy.log"

fail() {
    echo "[agy test] FAIL: $1" >&2
    exit 1
}

# Without agy: still links GEMINI.md, skips the rest
NO_AGY_HOME="$TMP_HOME/no-agy-home"
NO_AGY_BIN="$TMP_HOME/no-agy-bin"
mkdir -p "$NO_AGY_BIN"
for command_name in dirname mkdir mv ln readlink date; do
    ln -s "$(command -v "$command_name")" "$NO_AGY_BIN/$command_name"
done
PATH="$NO_AGY_BIN" HOME="$NO_AGY_HOME" /bin/bash "$CUR_DIR/install.sh" >"$TMP_HOME/no-agy.log" ||
    fail "install failed without agy"
grep -qF '[agy] agy not found' "$TMP_HOME/no-agy.log" || fail "missing agy was not reported"
[[ "$(readlink "$NO_AGY_HOME/.gemini/GEMINI.md")" == "$GLOBAL_SRC" ]] || fail "GEMINI.md was not linked without agy"

mkdir -p "$MOCK_BIN"
cat >"$MOCK_BIN/agy" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
# Swallow stdin like an interactive prompt would; install.sh must not feed it the list file
cat >/dev/null
case "$*" in
    "plugin import claude" | "mcp add "*)
        printf '%s\n' "$*" >>"$AGY_LOG"
        ;;
    *)
        exit 1
        ;;
esac
EOF
chmod +x "$MOCK_BIN/agy"

mkdir -p "$TMP_HOME/.gemini/config"
echo "my instructions" >"$GEMINI_MD"
HOOKS_JSON="$TMP_HOME/.gemini/config/hooks.json"
HOOK_COMMAND="bash \"$CUR_DIR/hooks/next_steps.sh\""
printf '{"mine": {"Stop": [{"command": "echo keep"}]}}\n' >"$HOOKS_JSON"

SETTINGS="$TMP_HOME/.gemini/antigravity-cli/settings.json"
REPO_SETTINGS="$CUR_DIR/settings.json"

PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(cat "$AGY_LOG")" == $'plugin import claude\nmcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest\nmcp add atlassian https://mcp.atlassian.com/v2/mcp' ]] ||
    fail "plugins were not imported or MCP servers were not added with their args: $(cat "$AGY_LOG")"
[[ "$(readlink "$GEMINI_MD")" == "$GLOBAL_SRC" ]] || fail "GEMINI.md was not linked to the shared file"
[[ "$(cat "$GEMINI_MD.bak")" == "my instructions" ]] || fail "existing GEMINI.md was not backed up"
[[ "$(jq -r '.["dotfiles-next-steps"].Stop[0].command' "$HOOKS_JSON")" == "$HOOK_COMMAND" ]] || fail "next steps hook was not registered"
[[ "$(jq -r '.mine.Stop[0].command' "$HOOKS_JSON")" == "echo keep" ]] || fail "install changed another hook"
[[ "$(jq -S . "$SETTINGS")" == "$(jq -S . "$REPO_SETTINGS")" ]] || fail "fresh install does not match the repo file"
# agy writes this file as 0600 itself (it holds the command allow list), so install keeps it that way
[[ -n "$(find "$SETTINGS" -perm 600)" ]] || fail "settings.json is not 0600"
compgen -G "$SETTINGS.*" >/dev/null && fail "temp file left behind for settings.json"

# Existing settings with local-only keys, a local-only deny rule and values the repo overrides
cat >"$SETTINGS" <<'EOF'
{
  "model": "local-model",
  "agentMode": "local-mode",
  "permissions": { "allow": ["command(ls)"], "deny": ["command(rm -rf)", "command(git push --force)"] },
  "trustedWorkspaces": ["/local/path"]
}
EOF
PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
cp "$SETTINGS" "$TMP_HOME/first-settings"
PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
# Every repo value is applied (deny aside, which is a union, checked below)
[[ "$(jq -s 'map(del(.permissions.deny)) | .[0] * .[1] == .[0]' "$SETTINGS" "$REPO_SETTINGS")" == true ]] || fail "repo values not applied"
[[ "$(jq -c .permissions.allow "$SETTINGS")" == '["command(ls)"]' ]] || fail "lost local permissions.allow (shallow merge?)"
[[ "$(jq -c .trustedWorkspaces "$SETTINGS")" == '["/local/path"]' ]] || fail "lost local-only key"
jq -e '.permissions.deny | index("command(git push --force)")' "$SETTINGS" >/dev/null || fail "dropped a local-only deny rule"
[[ "$(jq -s '.[1].permissions.deny - .[0].permissions.deny' "$SETTINGS" "$REPO_SETTINGS")" == '[]' ]] || fail "a repo deny rule is missing"
[[ "$(jq '.permissions.deny | length == (unique | length)' "$SETTINGS")" == true ]] || fail "deny rules are duplicated"
cmp -s "$SETTINGS" "$TMP_HOME/first-settings" || fail "rerun changed settings.json"
[[ -n "$(find "$SETTINGS" -perm 600)" ]] || fail "settings.json is not 0600 after merge"
compgen -G "$SETTINGS.*" >/dev/null && fail "temp file left behind"

# Invalid local JSON: left untouched and install still succeeds
echo '{oops' >"$SETTINGS"
PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null 2>&1 || fail "install failed on invalid settings.json"
[[ "$(cat "$SETTINGS")" == '{oops' ]] || fail "invalid settings.json was modified"
rm -f "$SETTINGS"

# The adapter asks for next steps once, only after a normal turn end without them
TRANSCRIPT="$TMP_HOME/transcript.jsonl"
run_hook() { jq -cn --arg t "$TRANSCRIPT" "{transcriptPath: \$t} + $1" | bash "$CUR_DIR/hooks/next_steps.sh"; }
printf '%s\n' '{"type":"USER_INPUT","content":"hi"}' '{"type":"PLANNER_RESPONSE","content":"Done"}' >"$TRANSCRIPT"
[[ "$(run_hook '{terminationReason: "NO_TOOL_CALL", continuationActive: false}' | jq -r '.decision')" == continue ]] ||
    fail "hook did not ask for next steps"
run_hook '{terminationReason: "NO_TOOL_CALL", continuationActive: false}' | jq -e '.reason | contains("Next steps:")' >/dev/null ||
    fail "hook did not pass the shared prompt"
[[ "$(run_hook '{terminationReason: "NO_TOOL_CALL", continuationActive: true}')" == '{}' ]] || fail "hook asked again in the same turn"
[[ "$(run_hook '{terminationReason: "USER_CANCELED", continuationActive: false}')" == '{}' ]] || fail "hook continued a canceled turn"
printf '%s\n' '{"type":"PLANNER_RESPONSE","content":"Done\n\nNext steps:\n1. x"}' >"$TRANSCRIPT"
[[ "$(run_hook '{terminationReason: "NO_TOOL_CALL", continuationActive: false}')" == '{}' ]] || fail "hook blocked an answer with next steps"
rm "$TRANSCRIPT"
[[ "$(run_hook '{terminationReason: "NO_TOOL_CALL", continuationActive: false}')" == '{}' ]] || fail "hook blocked without a transcript"

PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(cat "$GEMINI_MD.bak")" == "my instructions" ]] || fail "rerun overwrote the GEMINI.md backup"
stamped=("$GEMINI_MD".bak.*)
[[ ! -e "${stamped[0]}" ]] || fail "rerun made a timestamped backup of its own link"

# A real file in place of the link goes to .bak; the older .bak is kept under a timestamp
rm "$GEMINI_MD"
echo "edited" >"$GEMINI_MD"
PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(cat "$GEMINI_MD.bak")" == edited ]] || fail "install did not move the edited GEMINI.md to .bak"
stamped=("$GEMINI_MD".bak.*)
[[ ${#stamped[@]} -eq 1 && "$(cat "${stamped[0]}")" == "my instructions" ]] || fail "install did not keep the older GEMINI.md.bak under a timestamp"
[[ "$(readlink "$GEMINI_MD")" == "$GLOBAL_SRC" ]] || fail "install did not relink GEMINI.md"

HOME="$TMP_HOME" "$CUR_DIR/uninstall.sh" >/dev/null
[[ ! -L "$GEMINI_MD" && "$(cat "$GEMINI_MD")" == edited ]] || fail "uninstall did not restore GEMINI.md from .bak"
[[ ! -e "$GEMINI_MD.bak" ]] || fail "uninstall left GEMINI.md.bak"
[[ "$(jq -c 'keys' "$HOOKS_JSON")" == '["mine"]' ]] || fail "uninstall did not remove only the next steps hook"

echo "[agy test] OK"
