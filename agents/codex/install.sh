#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CODEX_DIR="$HOME/.codex"
HOOKS_DIR="$CODEX_DIR/hooks"
HOOK_SCRIPT="$HOOKS_DIR/next_steps.sh"
OLD_HOOK_SCRIPT="$HOOKS_DIR/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
# Global instructions shared with Claude
AGENTS_SRC="$(cd "$CUR_DIR/.." && pwd)/global.md"
AGENTS_MD="$CODEX_DIR/AGENTS.md"
CODEX_CONFIG="$CODEX_DIR/config.toml"
STATUS_LINE_CONFIG="$CUR_DIR/config/status-line.toml"
HOOK_COMMAND="bash \"$HOOK_SCRIPT\""
OLD_HOOK_COMMAND="python3 \"$OLD_HOOK_SCRIPT\""

if ! command -v yq >/dev/null 2>&1; then
    echo "[codex] yq is required to apply TOML settings; install the brew module first" >&2
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    echo "[codex] jq is required to update hooks.json; install the brew module first" >&2
    exit 1
fi

# Back up an existing real file, or a link to somewhere else, before linking
# .bak always holds the file moved away last (uninstall restores it); an older .bak gets a timestamp
link() {
    local src="$1" target="$2"
    if [[ -e "$target" && ! -L "$target" ]] ||
        [[ -L "$target" && "$(readlink "$target")" != "$src" ]]; then
        if [[ -e "$target.bak" || -L "$target.bak" ]]; then
            mv "$target.bak" "$target.bak.$(date +%Y%m%d%H%M%S)"
        fi
        mv "$target" "$target.bak"
        echo "[codex] Backed up existing $target to $target.bak"
    fi
    mkdir -p "$(dirname "$target")"
    ln -sfn "$src" "$target"
}

link "$AGENTS_SRC" "$AGENTS_MD"
link "$CUR_DIR/hooks/next_steps.sh" "$HOOK_SCRIPT"
if [[ -L "$OLD_HOOK_SCRIPT" ]]; then
    OLD_HOOK_TARGET="$(readlink "$OLD_HOOK_SCRIPT")"
    if [[ "$OLD_HOOK_TARGET" == "$CUR_DIR/hooks/next_steps.py" ||
        "$OLD_HOOK_TARGET" == "$CUR_DIR/hooks/next_steps_legacy.py" ]]; then
        rm "$OLD_HOOK_SCRIPT"
    fi
fi

if [[ -e "$CODEX_CONFIG" ]]; then
    TEMP_CONFIG="$(mktemp "$CODEX_DIR/config.toml.XXXXXX")"
    trap '[[ -z "${TEMP_CONFIG:-}" ]] || rm -f "$TEMP_CONFIG"; [[ -z "${TEMP_HOOK_CONFIG:-}" ]] || rm -f "$TEMP_HOOK_CONFIG"' EXIT
    yq ea -p toml -o toml \
        'select(fileIndex == 0).tui.status_line = select(fileIndex == 1).tui.status_line | select(fileIndex == 0)' \
        "$CODEX_CONFIG" "$STATUS_LINE_CONFIG" >"$TEMP_CONFIG"
    mv "$TEMP_CONFIG" "$CODEX_CONFIG"
    TEMP_CONFIG=""
else
    cp "$STATUS_LINE_CONFIG" "$CODEX_CONFIG"
fi

if [[ ! -f "$HOOK_CONFIG" ]]; then
    printf '{}\n' >"$HOOK_CONFIG"
fi
TEMP_HOOK_CONFIG="$(mktemp "$CODEX_DIR/hooks.json.XXXXXX")"
jq --arg command "$HOOK_COMMAND" --arg old_command "$OLD_HOOK_COMMAND" '
    .hooks = (.hooks // {}) |
    .hooks.Stop = (
        ((.hooks.Stop // []) | map(.hooks = ((.hooks // []) | map(select(.command != $old_command)))))
        | map(select(.hooks | length > 0))
        | if any(.[]; any(.hooks[]; .command == $command)) then . else . + [{"hooks": [{"type": "command", "command": $command, "timeout": 10, "statusMessage": "Preparing next steps"}]}] end
    )
' "$HOOK_CONFIG" >"$TEMP_HOOK_CONFIG"
mv "$TEMP_HOOK_CONFIG" "$HOOK_CONFIG"
TEMP_HOOK_CONFIG=""

echo "[codex] Next steps hook installed. Review and trust it with /hooks before it runs."

if ! command -v codex >/dev/null 2>&1; then
    echo "[codex] codex not found, skipping plugins."
else
    # </dev/null: keep codex from reading the list files the loops feed on stdin
    marketplaces="$(codex plugin marketplace list --json </dev/null 2>/dev/null | jq -r '.marketplaces[]?.name // empty' || true)"
    while read -r name source || [[ -n "$name" ]]; do
        case "$name" in
        "" | \#*) continue ;;
        esac
        if grep -qxF "$name" <<<"$marketplaces"; then
            echo "[codex] Marketplace $name already added."
        else
            codex plugin marketplace add "$source" </dev/null || echo "[codex] Failed to add marketplace $name, continuing."
        fi
    done <"$CUR_DIR/marketplaces.txt"

    installed_plugins="$(codex plugin list --json </dev/null 2>/dev/null | jq -r '.installed[]?.pluginId // empty' || true)"
    while read -r plugin || [[ -n "$plugin" ]]; do
        case "$plugin" in
        "" | \#*) continue ;;
        esac
        if grep -qxF "$plugin" <<<"$installed_plugins"; then
            echo "[codex] Plugin $plugin already installed."
        else
            codex plugin add "$plugin" </dev/null || echo "[codex] Failed to install plugin $plugin, continuing."
        fi
    done <"$CUR_DIR/plugins.txt"

    # Same list and format as agents/claude/install.sh; read -ra splits on whitespace without glob expansion
    while read -ra parts || [[ ${#parts[@]} -gt 0 ]]; do
        name="${parts[0]:-}"
        case "$name" in
        "" | \#*) continue ;;
        esac
        if codex mcp get "$name" >/dev/null 2>&1 </dev/null; then
            echo "[codex] MCP server $name already added."
        elif [[ "${parts[1]:-}" == http*://* ]]; then
            codex mcp add "$name" --url "${parts[1]}" </dev/null || echo "[codex] Failed to add MCP server $name, continuing."
        else
            # shortcut: args cannot contain spaces (no quoting support); edit config.toml directly if one does
            codex mcp add "$name" -- "${parts[@]:1}" </dev/null || echo "[codex] Failed to add MCP server $name, continuing."
        fi
    done <"$CUR_DIR/../mcps.txt"
fi
