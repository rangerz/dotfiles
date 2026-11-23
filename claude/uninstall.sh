#!/usr/bin/env bash
set -euo pipefail

TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"

# Replace the symlink with a real copy so the status line keeps working after the repo is removed
# 把 symlink 換成實體檔案，移除 repo 後 status line 仍可運作
if [[ -L "$TARGET" ]]; then
    # Plain readlink/rm/cp for macOS (BSD cp has no --remove-destination); install.sh links an absolute path
    # 為相容 macOS 只用基本 readlink/rm/cp;install.sh 建立的是絕對路徑
    src="$(readlink "$TARGET")"
    rm "$TARGET"
    cp "$src" "$TARGET"
    echo "[claude] Replaced symlink with a copy at $TARGET"
fi

# Remove the CLAUDE.md link only if it points into this repo
# 只在 CLAUDE.md 連結指向本 repo 時才移除
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [[ -L "$CLAUDE_MD" && "$(readlink "$CLAUDE_MD")" == "$CUR_DIR/CLAUDE.md" ]]; then
    rm "$CLAUDE_MD"
    echo "[claude] Removed symlink $CLAUDE_MD"
fi

echo "[claude] Uninstallation completed."
