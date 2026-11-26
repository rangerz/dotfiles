#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="$HOME/.codex"
HOOK_SCRIPT="$CODEX_DIR/hooks/next_steps.py"
HOOK_CONFIG="$CODEX_DIR/hooks.json"
HOOK_COMMAND="python3 \"$HOOK_SCRIPT\""

if [[ -f "$HOOK_CONFIG" ]]; then
    python3 - "$HOOK_CONFIG" "$HOOK_COMMAND" <<'PY'
import json
import os
import sys
import tempfile

path, command = sys.argv[1:]
with open(path, encoding="utf-8") as stream:
    config = json.load(stream)

hooks = config.get("hooks", {})
stop_hooks = hooks.get("Stop", [])
for group in stop_hooks:
    group["hooks"] = [
        handler for handler in group.get("hooks", [])
        if handler.get("command") != command
    ]
hooks["Stop"] = [group for group in stop_hooks if group.get("hooks")]
if not hooks["Stop"]:
    hooks.pop("Stop")
if not hooks:
    config.pop("hooks")

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
fi

if [[ -L "$HOOK_SCRIPT" && "$(readlink "$HOOK_SCRIPT")" == "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/hooks/next_steps.py" ]]; then
    rm "$HOOK_SCRIPT"
fi

echo "[codex] Next steps hook removed."
