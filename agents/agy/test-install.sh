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

mkdir -p "$TMP_HOME/.gemini"
echo "my instructions" >"$GEMINI_MD"

PATH="$MOCK_BIN:$PATH" AGY_LOG="$AGY_LOG" HOME="$TMP_HOME" "$CUR_DIR/install.sh" >/dev/null
[[ "$(cat "$AGY_LOG")" == $'plugin import claude\nmcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest\nmcp add atlassian https://mcp.atlassian.com/v2/mcp' ]] ||
    fail "plugins were not imported or MCP servers were not added with their args: $(cat "$AGY_LOG")"
[[ "$(readlink "$GEMINI_MD")" == "$GLOBAL_SRC" ]] || fail "GEMINI.md was not linked to the shared file"
[[ "$(cat "$GEMINI_MD.bak")" == "my instructions" ]] || fail "existing GEMINI.md was not backed up"

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

echo "[agy test] OK"
