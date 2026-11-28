#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"

# Only touch our own link (install.sh links an absolute path)
if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$CUR_DIR/ccstatusline.json" ]]; then
    rm "$TARGET"
    # -e follows links, so a dangling .bak (e.g. a link to a path the repo no longer has) is not restored
    if [[ -e "$TARGET.bak" ]]; then
        mv "$TARGET.bak" "$TARGET"
        echo "[claude] Restored $TARGET from $TARGET.bak"
    else
        # A real copy keeps the status line working after the repo is removed
        cp "$CUR_DIR/ccstatusline.json" "$TARGET"
        echo "[claude] Replaced symlink with a copy at $TARGET"
    fi
fi

# Remove the CLAUDE.md link only if it points into this repo
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [[ -L "$CLAUDE_MD" && "$(readlink "$CLAUDE_MD")" == "$(cd "$CUR_DIR/.." && pwd)/global.md" ]]; then
    rm "$CLAUDE_MD"
    echo "[claude] Removed symlink $CLAUDE_MD"
    # Put back the file install.sh backed up
    if [[ -e "$CLAUDE_MD.bak" || -L "$CLAUDE_MD.bak" ]]; then
        mv "$CLAUDE_MD.bak" "$CLAUDE_MD"
        echo "[claude] Restored $CLAUDE_MD from $CLAUDE_MD.bak"
    fi
fi

echo "[claude] Uninstallation completed."
