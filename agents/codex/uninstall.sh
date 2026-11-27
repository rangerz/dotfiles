#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="$HOME/.codex"
HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.sh"
OLD_HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
HOOK_COMMAND="bash \"$HOOK_SCRIPT\""
OLD_HOOK_COMMAND="python3 \"$OLD_HOOK_SCRIPT\""

if [[ -f "$HOOK_CONFIG" ]] && ! command -v jq >/dev/null 2>&1; then
    echo "[codex] jq is required to update hooks.json; install the brew module first" >&2
    exit 1
fi

if [[ -f "$HOOK_CONFIG" ]]; then
    TEMP_HOOK_CONFIG="$(mktemp "$CODEX_DIR/hooks.json.XXXXXX")"
    jq --arg command "$HOOK_COMMAND" --arg old_command "$OLD_HOOK_COMMAND" '
    if .hooks.Stop then
        .hooks.Stop = (
            .hooks.Stop
            | map(.hooks = ((.hooks // []) | map(select(.command != $command and .command != $old_command))))
            | map(select(.hooks | length > 0))
        )
    else . end |
    if (.hooks.Stop // [] | length) == 0 then del(.hooks.Stop) else . end |
    if (.hooks // {} | length) == 0 then del(.hooks) else . end
' "$HOOK_CONFIG" >"$TEMP_HOOK_CONFIG"
    mv "$TEMP_HOOK_CONFIG" "$HOOK_CONFIG"
fi

if [[ -L "$HOOK_SCRIPT" && "$(readlink "$HOOK_SCRIPT")" == "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/hooks/next_steps.sh" ]]; then
    rm "$HOOK_SCRIPT"
fi
if [[ -L "$OLD_HOOK_SCRIPT" ]]; then
    CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    OLD_HOOK_TARGET="$(readlink "$OLD_HOOK_SCRIPT")"
    if [[ "$OLD_HOOK_TARGET" == "$CUR_DIR/hooks/next_steps.py" ||
        "$OLD_HOOK_TARGET" == "$CUR_DIR/hooks/next_steps_legacy.py" ]]; then
        rm "$OLD_HOOK_SCRIPT"
    fi
fi

AGENTS_MD="$CODEX_DIR/AGENTS.md"
if [[ -L "$AGENTS_MD" && "$(readlink "$AGENTS_MD")" == "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)/global.md" ]]; then
    rm "$AGENTS_MD"
    echo "[codex] Removed symlink $AGENTS_MD"
    # Put back the file install.sh backed up
    if [[ -e "$AGENTS_MD.bak" || -L "$AGENTS_MD.bak" ]]; then
        mv "$AGENTS_MD.bak" "$AGENTS_MD"
        echo "[codex] Restored $AGENTS_MD from $AGENTS_MD.bak"
    fi
fi

echo "[codex] Next steps hook removed."
