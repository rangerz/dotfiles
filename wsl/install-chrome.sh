#!/usr/bin/env bash
# Install Google Chrome (stable) inside WSL via the official .deb.
# 在 WSL 內用官方 .deb 安裝 Google Chrome(stable)。
#
# The .deb bootstraps Google's apt repo, so later `apt upgrade` keeps Chrome
# up to date automatically — no need to re-download a new .deb each time.
# .deb 會自動設定好 Google 的 apt 來源,之後 `apt upgrade` 就會自動更新 Chrome,
# 不必每次手動重新下載新的 .deb。
#
# Usage 用法:
#   ./install-chrome.sh              # install if missing (idempotent 冪等)
#   ./install-chrome.sh --reinstall  # force reinstall 強制重裝
set -euo pipefail

CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }
has()    { command -v "$1" >/dev/null 2>&1; }

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
    # 冪等:已安裝就跳過,除非指定 --reinstall。
    if dpkg -s google-chrome-stable >/dev/null 2>&1 && [[ "${1:-}" != "--reinstall" ]]; then
        echo "[chrome] Already installed: $(google-chrome-stable --version 2>/dev/null || echo unknown)."
        echo "[chrome] Pass --reinstall to force."
        return 0
    fi

    # Not `local`: the EXIT trap runs after main returns, so deb must stay
    # in scope for cleanup to reach it. 不用 local:EXIT trap 在 main 返回後才跑,
    # deb 需維持全域作用域,清理才抓得到。
    deb="$(mktemp --suffix=.deb)"
    # mktemp is 0600; make it world-readable so apt's `_apt` sandbox user can
    # read it (otherwise apt warns and downloads as root).
    # mktemp 預設 0600;放寬成可讀,apt 的 _apt 沙箱使用者才讀得到(否則會退回用 root 下載並告警)。
    chmod 644 "$deb"
    # Always clean up the downloaded .deb, even if the install fails.
    # 即使安裝失敗也一定清掉下載的 .deb。
    trap 'rm -f "$deb"' EXIT

    echo "[chrome] Downloading Chrome .deb..."
    curl -fSL -o "$deb" "$CHROME_DEB_URL"

    echo "[chrome] Installing (apt resolves dependencies automatically)..."
    sudo apt-get install -y "$deb"

    echo "[chrome] Done: $(google-chrome-stable --version 2>/dev/null || echo installed)"
}

main "$@"
