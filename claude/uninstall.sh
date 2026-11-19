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

echo "[claude] Uninstallation completed."
