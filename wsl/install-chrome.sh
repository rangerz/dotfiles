#!/usr/bin/env bash
# Install Google Chrome (stable) inside WSL via the official .deb.
#
# The .deb bootstraps Google's apt repo, so later `apt upgrade` keeps Chrome
# up to date automatically — no need to re-download a new .deb each time.
#
# Usage:
#   ./install-chrome.sh              # install if missing (idempotent)
#   ./install-chrome.sh --reinstall  # force reinstall
set -euo pipefail

CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }
has() { command -v "$1" >/dev/null 2>&1; }

main() {
    if ! is_wsl; then
        echo "[chrome] Not running under WSL; skipping."
        return 0
    fi
    if ! has apt-get; then
        echo "[chrome] Non-apt distro; install Chrome manually." >&2
        return 0
    fi

    # Idempotent: skip if already installed unless --reinstall is given.
    if dpkg -s google-chrome-stable >/dev/null 2>&1 && [[ "${1:-}" != "--reinstall" ]]; then
        echo "[chrome] Already installed: $(google-chrome-stable --version 2>/dev/null || echo unknown)."
        echo "[chrome] Pass --reinstall to force."
        return 0
    fi

    # Not `local`: the EXIT trap runs after main returns, so deb must stay
    # in scope for cleanup to reach it.
    deb="$(mktemp --suffix=.deb)"
    # mktemp is 0600; make it world-readable so apt's `_apt` sandbox user can
    # read it (otherwise apt warns and downloads as root).
    chmod 644 "$deb"
    # Always clean up the downloaded .deb, even if the install fails.
    trap 'rm -f "$deb"' EXIT

    echo "[chrome] Downloading Chrome .deb..."
    curl -fSL -o "$deb" "$CHROME_DEB_URL"

    echo "[chrome] Installing (apt resolves dependencies automatically)..."
    sudo apt-get install -y "$deb"

    echo "[chrome] Done: $(google-chrome-stable --version 2>/dev/null || echo installed)"
}

main "$@"
