#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CODEX_DIR="$HOME/.codex"
HOOKS_DIR="$CODEX_DIR/hooks"
HOOK_SCRIPT="$HOOKS_DIR/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
HOOK_COMMAND="python3 \"$HOOK_SCRIPT\""

mkdir -p "$HOOKS_DIR"
if [[ -e "$HOOK_SCRIPT" && ! -L "$HOOK_SCRIPT" ]] ||
    [[ -L "$HOOK_SCRIPT" && "$(readlink "$HOOK_SCRIPT")" != "$CUR_DIR/hooks/next_steps.py" ]]; then
    mv "$HOOK_SCRIPT" "$HOOK_SCRIPT.bak"
    echo "[codex] Backed up existing hook to $HOOK_SCRIPT.bak"
fi
ln -sfn "$CUR_DIR/hooks/next_steps.py" "$HOOK_SCRIPT"

python3 - "$HOOK_CONFIG" "$HOOK_COMMAND" <<'PY'
import json
import os
import sys
import tempfile

path, command = sys.argv[1:]
config = {}
if os.path.exists(path):
    with open(path, encoding="utf-8") as stream:
        config = json.load(stream)

hooks = config.setdefault("hooks", {})
stop_hooks = hooks.setdefault("Stop", [])
entry = {
    "hooks": [
        {
            "type": "command",
            "command": command,
            "timeout": 10,
            "statusMessage": "Preparing next steps",
        }
    ]
}

already_configured = any(
    handler.get("command") == command
    for group in stop_hooks
    for handler in group.get("hooks", [])
)
if not already_configured:
    stop_hooks.append(entry)

directory = os.path.dirname(path)
fd, temporary_path = tempfile.mkstemp(prefix="hooks.json.", dir=directory)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as stream:
        json.dump(config, stream, indent=2, ensure_ascii=False)
        stream.write("\n")
    os.chmod(temporary_path, 0o644)
    os.replace(temporary_path, path)
except Exception:
    if os.path.exists(temporary_path):
        os.unlink(temporary_path)
    raise
PY

echo "[codex] Next steps hook installed. Review and trust it with /hooks."
