#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
GEMINI_MD="$HOME/.gemini/GEMINI.md"

if [[ -L "$GEMINI_MD" && "$(readlink "$GEMINI_MD")" == "$(cd "$CUR_DIR/.." && pwd)/global.md" ]]; then
    rm "$GEMINI_MD"
    echo "[agy] Removed symlink $GEMINI_MD"
    # Put back the file install.sh backed up
    if [[ -e "$GEMINI_MD.bak" || -L "$GEMINI_MD.bak" ]]; then
        mv "$GEMINI_MD.bak" "$GEMINI_MD"
        echo "[agy] Restored $GEMINI_MD from $GEMINI_MD.bak"
    fi
fi

# Imported plugins and MCP servers stay, like the Claude and Codex uninstallers
