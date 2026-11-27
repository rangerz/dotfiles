#!/usr/bin/env bash
# Uninstall Google Chrome (stable) from WSL, undoing wsl/install-chrome.sh.
#
# Usage:
#   ./uninstall-chrome.sh          # purge the package + autoremove deps
#   ./uninstall-chrome.sh --repo   # also remove Google's apt repo + keyring
set -euo pipefail

is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }
has() { command -v "$1" >/dev/null 2>&1; }

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
    if dpkg -s google-chrome-stable >/dev/null 2>&1; then
        echo "[chrome] Purging google-chrome-stable..."
        sudo apt-get purge -y google-chrome-stable
        echo "[chrome] Removing now-unused dependencies..."
        sudo apt-get autoremove -y
    else
        echo "[chrome] google-chrome-stable is not installed."
    fi

    # Purging the package leaves Google's apt repo behind; --repo clears it too.
    # User data (~/.config/google-chrome) is never touched.
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
