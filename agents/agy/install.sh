#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Global instructions shared with Claude and Codex
GLOBAL_SRC="$(cd "$CUR_DIR/.." && pwd)/global.md"
GEMINI_MD="$HOME/.gemini/GEMINI.md"

AGENT=agy
# shellcheck source=agents/link.sh
source "$CUR_DIR/../link.sh"

link "$GLOBAL_SRC" "$GEMINI_MD"

if ! command -v agy >/dev/null 2>&1; then
    echo "[agy] agy not found, skipping plugins and MCP servers."
    exit 0
fi

# agy cannot add GitHub marketplaces, so mirror the plugins agents/claude/install.sh installed
# It skips plugins it already imported; </dev/null keeps agy off the list file the loop below feeds on stdin
agy plugin import claude </dev/null || echo "[agy] Failed to import plugins from Claude, continuing."

# Same list and format as agents/claude/install.sh; read -ra splits on whitespace without glob expansion
while read -ra parts || [[ ${#parts[@]} -gt 0 ]]; do
    name="${parts[0]:-}"
    case "$name" in
    "" | \#*) continue ;;
    esac
    # `agy mcp add` adds or updates, so a rerun is safe
    if [[ "${parts[1]:-}" == http*://* ]]; then
        agy mcp add "$name" "${parts[1]}" </dev/null || echo "[agy] Failed to add MCP server $name, continuing."
    else
        # shortcut: args cannot contain spaces (no quoting support); use `agy mcp add` by hand if one does
        agy mcp add "$name" -- "${parts[@]:1}" </dev/null || echo "[agy] Failed to add MCP server $name, continuing."
    fi
done <"$CUR_DIR/../mcps.txt"
