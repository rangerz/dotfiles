#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CODEX_DIR="$HOME/.codex"
HOOKS_DIR="$CODEX_DIR/hooks"
HOOK_SCRIPT="$HOOKS_DIR/next_steps.sh"
OLD_HOOK_SCRIPT="$HOOKS_DIR/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
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

mkdir -p "$HOOKS_DIR"
if [[ -e "$HOOK_SCRIPT" && ! -L "$HOOK_SCRIPT" ]] ||
    [[ -L "$HOOK_SCRIPT" && "$(readlink "$HOOK_SCRIPT")" != "$CUR_DIR/hooks/next_steps.sh" ]]; then
    mv "$HOOK_SCRIPT" "$HOOK_SCRIPT.bak"
    echo "[codex] Backed up existing hook to $HOOK_SCRIPT.bak"
fi
ln -sfn "$CUR_DIR/hooks/next_steps.sh" "$HOOK_SCRIPT"
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

if ! command -v codex >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "[codex] codex or jq not found, skipping plugins."
else
    installed_plugins="$(codex plugin list --json 2>/dev/null | jq -r '.installed[]?.pluginId // empty' || true)"
    while read -r plugin || [[ -n "$plugin" ]]; do
        case "$plugin" in
        "" | \#*) continue ;;
        esac
        if grep -qxF "$plugin" <<<"$installed_plugins"; then
            echo "[codex] Plugin $plugin already installed."
        else
            codex plugin add "$plugin" || echo "[codex] Failed to install plugin $plugin, continuing."
        fi
    done <"$CUR_DIR/plugins.txt"
fi
