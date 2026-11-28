#!/usr/bin/env bash
# Self-check for install.sh's settings.json merge and CLAUDE.md link (to the shared agents/global.md), run against a throwaway HOME (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

# A stub claude that logs what install.sh asks of it, so the plugin/MCP loops stay offline
# It reports one marketplace (in different case) and one plugin as already installed
CLAUDE_LOG="$TMP_HOME/claude.log"
mkdir -p "$TMP_HOME/bin" "$TMP_HOME/.claude"
cat >"$TMP_HOME/bin/claude" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
# Swallow stdin like an interactive prompt would; install.sh must not feed it the list files
cat >/dev/null
case "$*" in
    "plugin marketplace list --json") printf '[{"repo":"dietrichgebert/PONYTAIL"}]\n' ;;
    "plugin list --json") printf '[{"id":"ponytail@ponytail"}]\n' ;;
    # A server exists once a previous run added it
    "mcp get "*) grep -q "^mcp add .* ${3:?} " "$CLAUDE_LOG" 2>/dev/null ;;
    "plugin marketplace add "* | "plugin install "* | "mcp add "*) printf '%s\n' "$*" >>"$CLAUDE_LOG" ;;
    *) exit 1 ;;
esac
EOF
chmod +x "$TMP_HOME/bin/claude"

SETTINGS="$TMP_HOME/.claude/settings.json"
REPO="$CUR_DIR/settings.json"
run_install() { env -u XDG_CONFIG_HOME HOME="$TMP_HOME" PATH="$TMP_HOME/bin:$PATH" CLAUDE_LOG="$CLAUDE_LOG" "$CUR_DIR/install.sh" >/dev/null 2>&1; }
fail() {
    echo "[claude test] FAIL: $1" >&2
    exit 1
}
key() { jq -c "$1" "$SETTINGS"; }

# Fresh machine: no settings.json yet
run_install
[[ "$(jq -S . "$SETTINGS")" == "$(jq -S . "$REPO")" ]] || fail "fresh install does not match the repo file"

# Plugins: installed ones are skipped (marketplaces matched case-insensitively), the rest are added in file order
grep -qi 'ponytail' "$CLAUDE_LOG" && fail "installed marketplace or plugin was added again"
last_plugin="$(grep '^plugin ' "$CUR_DIR/plugins.txt" | tail -n 1 | cut -d' ' -f2)"
grep -qxF "plugin install $last_plugin" "$CLAUDE_LOG" || fail "last plugin in plugins.txt ($last_plugin) was not installed"
[[ "$(grep -c '^plugin install ' "$CLAUDE_LOG")" -eq "$(($(grep -c '^plugin ' "$CUR_DIR/plugins.txt") - 1))" ]] ||
    fail "not every missing plugin was installed"
[[ "$(grep -c '^plugin marketplace add ' "$CLAUDE_LOG")" -eq "$(($(grep -c '^marketplace ' "$CUR_DIR/plugins.txt") - 1))" ]] ||
    fail "not every missing marketplace was added"
# MCP: http servers use --transport http, stdio servers keep their args after --
[[ "$(grep '^mcp add ' "$CLAUDE_LOG")" == $'mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest\nmcp add --scope user --transport http atlassian https://mcp.atlassian.com/v2/mcp' ]] ||
    fail "MCP servers were not added with their args: $(grep '^mcp add ' "$CLAUDE_LOG")"
run_install
[[ "$(grep -c '^mcp add ' "$CLAUDE_LOG")" -eq 2 ]] || fail "rerun added an MCP server again"

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
AGENTS_MD="$(cd "$CUR_DIR/.." && pwd)/global.md"
rm -f "$CLAUDE_MD" "$CLAUDE_MD.bak"
ln -s "$TMP_HOME/other.md" "$CLAUDE_MD"
run_install
run_install
[[ "$(readlink "$CLAUDE_MD")" == "$AGENTS_MD" ]] || fail "install did not link CLAUDE.md to the shared global.md"
[[ "$(readlink "$CLAUDE_MD.bak")" == "$TMP_HOME/other.md" ]] || fail "install did not back up the other CLAUDE.md link"

# Our old link to agents/claude/CLAUDE.md is replaced without a backup
rm -f "$CLAUDE_MD" "$CLAUDE_MD.bak"
ln -s "$CUR_DIR/CLAUDE.md" "$CLAUDE_MD"
run_install
[[ "$(readlink "$CLAUDE_MD")" == "$AGENTS_MD" ]] || fail "install did not replace the old CLAUDE.md link"
[[ ! -e "$CLAUDE_MD.bak" && ! -L "$CLAUDE_MD.bak" ]] || fail "install backed up the old CLAUDE.md link"

# The file moved away last goes to .bak; an existing .bak is kept under a timestamp
ln -s "$TMP_HOME/other.md" "$CLAUDE_MD.bak"
rm "$CLAUDE_MD"
echo "edited" >"$CLAUDE_MD"
run_install
[[ ! -L "$CLAUDE_MD.bak" && "$(cat "$CLAUDE_MD.bak")" == edited ]] || fail "install did not move the edited CLAUDE.md to .bak"
stamped=("$CLAUDE_MD".bak.*)
[[ ${#stamped[@]} -eq 1 && "$(readlink "${stamped[0]}")" == "$TMP_HOME/other.md" ]] || fail "install did not keep the older CLAUDE.md.bak under a timestamp"

# Uninstall removes our link and puts the .bak back
env -u XDG_CONFIG_HOME HOME="$TMP_HOME" "$CUR_DIR/uninstall.sh" >/dev/null
[[ ! -L "$CLAUDE_MD" && "$(cat "$CLAUDE_MD")" == edited ]] || fail "uninstall did not restore CLAUDE.md from .bak"
[[ ! -e "$CLAUDE_MD.bak" && ! -L "$CLAUDE_MD.bak" ]] || fail "uninstall left CLAUDE.md.bak"

echo "[claude test] OK"
