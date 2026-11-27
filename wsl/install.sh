#!/usr/bin/env bash
# WSL-only setup: install packages that only make sense inside WSL.
set -euo pipefail

# ---------------------------------------------------------------------------
# Add WSL-only apt packages here, one per line. Inline "# ..." notes are fine.
# ---------------------------------------------------------------------------
WSL_APT_PACKAGES=(
    wslu            # wslview/wslvar/wslsys... — open files & URLs with Windows default apps
    build-essential # compilers and build tools
    git             # version control
    curl            # downloads
    fonts-noto-cjk  # Noto CJK fonts
)

# WSL check (matches shell/shell.sh)
is_wsl() { grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; }

# Install only the missing packages so re-runs stay fast and idempotent.
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
