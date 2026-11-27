#!/usr/bin/env bash
set -euo pipefail

TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"

# Replace the symlink with a real copy so the status line keeps working after the repo is removed
if [[ -L "$TARGET" ]]; then
    # Plain readlink/rm/cp for macOS (BSD cp has no --remove-destination); install.sh links an absolute path
    src="$(readlink "$TARGET")"
    rm "$TARGET"
    cp "$src" "$TARGET"
    echo "[claude] Replaced symlink with a copy at $TARGET"
fi

# Remove the CLAUDE.md link only if it points into this repo
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [[ -L "$CLAUDE_MD" && "$(readlink "$CLAUDE_MD")" == "$(cd "$CUR_DIR/.." && pwd)/global.md" ]]; then
    rm "$CLAUDE_MD"
    echo "[claude] Removed symlink $CLAUDE_MD"
fi

echo "[claude] Uninstallation completed."
