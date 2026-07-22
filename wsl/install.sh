#!/usr/bin/env bash
# WSL-only setup: install packages that only make sense inside WSL.
# WSL 專屬設定:安裝只在 WSL 環境才需要的套件。
set -euo pipefail

# ---------------------------------------------------------------------------
# Add WSL-only apt packages here, one per line. Inline "# ..." notes are fine.
# 在這裡新增 WSL 專屬的 apt 套件,一行一個,行內 "# ..." 註解可保留。
# ---------------------------------------------------------------------------
WSL_APT_PACKAGES=(
    wslu # wslview/wslvar/wslsys... — open files & URLs with Windows default apps
    build-essential # 編譯工具
    git # 程式碼版本控制
    curl # 下載工具
    fonts-noto-cjk # Noto CJK 字型
)

# WSL check (matches shell/shell.sh)
is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }

# Install only the missing packages so re-runs stay fast and idempotent.
# 只安裝尚未安裝的套件,讓重複執行既快又冪等。
install_apt_packages() {
    local missing=() pkg
    for pkg in "${WSL_APT_PACKAGES[@]}"; do
        dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    if ((${#missing[@]} == 0)); then
        echo "[WSL] All apt packages already installed: ${WSL_APT_PACKAGES[*]}"
        return 0
    fi

    echo "[WSL] Installing: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
}

main() {
    if ! is_wsl; then
        echo "[WSL] Not running under WSL; skipping."
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        install_apt_packages
    else
        echo "[WSL] Non-apt distro; install these manually: ${WSL_APT_PACKAGES[*]}" >&2
        return 0
    fi

    echo "[WSL] Done."
}

main "$@"
