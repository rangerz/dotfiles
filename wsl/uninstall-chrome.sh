#!/usr/bin/env bash
# Uninstall Google Chrome (stable) from WSL, undoing wsl/install-chrome.sh.
# 從 WSL 移除 Google Chrome(stable),還原 wsl/install-chrome.sh 的安裝。
#
# Usage 用法:
#   ./uninstall-chrome.sh          # purge the package + autoremove deps
#                                  # 移除套件並清掉孤兒依賴
#   ./uninstall-chrome.sh --repo   # also remove Google's apt repo + keyring
#                                  # 順便移除 Google 的 apt 來源與金鑰
set -euo pipefail

is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }
has()    { command -v "$1" >/dev/null 2>&1; }

main() {
    if ! is_wsl; then
        echo "[chrome] Not running under WSL; skipping."
        return 0
    fi
    if ! has apt-get; then
        echo "[chrome] Non-apt distro; remove Chrome manually." >&2
        return 0
    fi

    # Idempotent: nothing to purge if it's already gone.
    # 冪等:已經移除就不用再 purge。
    if dpkg -s google-chrome-stable >/dev/null 2>&1; then
        echo "[chrome] Purging google-chrome-stable..."
        sudo apt-get purge -y google-chrome-stable
        echo "[chrome] Removing now-unused dependencies..."
        sudo apt-get autoremove -y
    else
        echo "[chrome] google-chrome-stable is not installed."
    fi

    # Purging the package leaves Google's apt repo behind; --repo clears it too.
    # 未加 user data (~/.config/google-chrome),那是使用者資料,不動。
    # purge 套件不會移除 Google 的 apt 來源,--repo 才會一併清掉。
    if [[ "${1:-}" == "--repo" ]]; then
        echo "[chrome] Removing Google's apt repo and keyring..."
        sudo rm -f /etc/apt/sources.list.d/google-chrome.list \
                   /etc/apt/trusted.gpg.d/google-chrome.gpg \
                   /etc/apt/keyrings/google-chrome.gpg
        sudo apt-get update
    fi

    echo "[chrome] Done."
}

main "$@"
