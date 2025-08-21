#!/usr/bin/env bash
# Install zsh on various Linux distros and set it as the default shell.
set -euo pipefail

# Detect package manager and install zsh
install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "[OK] zsh already installed"
        return
    fi

    echo "[INFO] Installing zsh via detected package manager..."
    # Ubuntu/Debian
    if command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zsh curl git
    # Fedora/RHEL/CentOS
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh
    # Arch/Manjaro
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm zsh
    # Alpine
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache zsh
    # openSUSE
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper --non-interactive install zsh
    # Gentoo
    elif command -v emerge >/dev/null 2>&1; then
        sudo emerge --ask=n app-shells/zsh
    else
        echo "[ERR] Unsupported distro. Install zsh manually with your package manager."
        exit 1
    fi

    echo "[OK] zsh installed"
}

# Ensure the zsh binary path is present in /etc/shells for chsh
ensure_shells_list() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        echo "[ERR] zsh binary not found after installation"
        exit 1
    fi

    if [[ -r /etc/shells ]] && grep -qxF "$zsh_path" /etc/shells; then
        echo "[OK] $zsh_path already in /etc/shells"
    else
        echo "[INFO] Adding $zsh_path to /etc/shells"
        # append safely
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
}

# Set zsh as the user's default login shell
set_default_shell() {
    local zsh_path current_shell
    zsh_path="$(command -v zsh)"
    current_shell="${SHELL:-}"

    if [[ "$current_shell" == "$zsh_path" ]]; then
        echo "[OK] zsh already your default shell: $current_shell"
        return
    fi

    if ! command -v chsh >/dev/null 2>&1; then
        echo "[WARN] chsh not found; this system may lack util-linux or equivalent"
        echo "       Please change your login shell manually or install chsh (util-linux)."
        return
    fi

    # Do not use sudo here or you'll change root's shell on many distros
    echo "[INFO] Setting default shell with: chsh -s $zsh_path"
    chsh -s "$zsh_path" || {
        echo "[WARN] chsh failed. Ensure $zsh_path is in /etc/shells and try again."
        return
    }

    echo "[OK] Default shell changed to zsh. Re-login or run: exec zsh"
}

main() {
    # Fast path if already default zsh
    if command -v zsh >/dev/null 2>&1 && [[ "${SHELL:-}" == "$(command -v zsh)" ]]; then
        echo "[OK] zsh is installed and already your default shell."
        exit 0
    fi

    install_zsh
    ensure_shells_list
    set_default_shell

    # Ensure user has a zshrc to avoid first-run wizard if desired
    if [[ ! -f "${ZDOTDIR:-$HOME}/.zshrc" ]]; then
        echo "[INFO] Creating a minimal ~/.zshrc"
        cat >>"${ZDOTDIR:-$HOME}/.zshrc" <<'EOF'
# Minimal zshrc created by installer
autoload -Uz compinit && compinit
setopt prompt_subst
PROMPT='%n@%m:%~ %# '
EOF
    fi

    echo "[DONE] To start using zsh now, run: exec zsh"
}

main "$@"
