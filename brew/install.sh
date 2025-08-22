#!/usr/bin/env bash
# Cross-platform Homebrew bootstrap (Linux + macOS)
# Purpose: Install Homebrew with prerequisites, persist shell env, and auto-install from Brewfile if present

set -euo pipefail

# Install Linux prerequisites per official guidance
install_linux_requirements() {
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y build-essential procps curl file git
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf groupinstall -y 'Development Tools'
        sudo dnf install -y procps-ng curl file git
    elif command -v yum >/dev/null 2>&1; then
        sudo yum groupinstall -y 'Development Tools'
        sudo yum install -y procps-ng curl file git
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm base-devel procps-ng curl file git
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache build-base procps curl file git
    else
        echo "Unsupported Linux distro. Please install gcc/make, procps, curl, file, git manually."
        exit 1
    fi
}

# Soft-check Xcode Command Line Tools on macOS; only warn
check_xcode_clt() {
    if ! xcode-select -p >/dev/null 2>&1; then
        echo "[WARN] Xcode Command Line Tools not detected."
        echo "       Homebrew may require CLT. Install with: xcode-select --install"
    fi
}

# Install Homebrew non-interactively
install_homebrew() {
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Activate brew for current session
eval_brew_shellenv_now() {
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
        if [[ -x "$prefix/bin/brew" ]]; then
            eval "$("$prefix/bin/brew" shellenv)"
            return
        fi
    done
    if command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
    fi
}

# Add a line to a rc file only if it's missing
add_line_if_missing() {
    # $1: file path, $2: line
    local file="$1"
    local line="$2"

    # Ensure file exists
    mkdir -p "$(dirname "$file")"
    touch "$file"

    # Append only if the exact same line is not present
    if ! grep -qsF "$line" "$file" 2>/dev/null; then
        printf '\n# Homebrew shell environment\n%s\n' "$line" >>"$file"
        echo "Updated: $file"
    else
        echo "Unchanged: $file"
    fi
}

# Persist Homebrew shellenv into common Bash and Zsh startup files
persist_brew_shellenv() {
    local brew_bin prefix line
    brew_bin="$(command -v brew || true)"
    if [[ -z "$brew_bin" ]]; then
        echo "brew not found in PATH after installation"
        exit 1
    fi

    prefix="$("$brew_bin" --prefix)"
    line="eval \"\$($prefix/bin/brew shellenv)\""

    local os="$(uname -s)"
    local zhome="${ZDOTDIR:-$HOME}"
    local targets=()

    case "$os" in
    Darwin)
        targets=(
            "$zhome/.zprofile"
            "$HOME/.bash_profile"
        )
        ;;
    Linux)
        targets=(
            "$zhome/.zshrc"
            "$HOME/.bashrc"
        )
        ;;
    *)
        targets=("$HOME/.profile")
        ;;
    esac

    echo "Persisting Homebrew environment..."
    for rc in "${targets[@]}"; do
        add_line_if_missing "$rc" "$line"
    done
}

# Install from Brewfile
install_from_brewfile() {
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    local brewfile="$script_dir/Brewfile"

    if [[ -f "$brewfile" ]]; then
        echo "Brewfile detected at $brewfile, running: brew bundle install --file=$brewfile"
        brew bundle install --file="$brewfile"
    else
        echo "No Brewfile found in $script_dir; skipping brew bundle install."
    fi
}

main() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew already installed. Skipping installation."
    else
        case "$(uname -s)" in
        Linux)
            echo "Detected Linux. Installing prerequisites..."
            install_linux_requirements
            echo "Installing Homebrew..."
            install_homebrew
            ;;
        Darwin)
            echo "Detected macOS. Checking Xcode CLT..."
            check_xcode_clt
            echo "Installing Homebrew..."
            install_homebrew
            ;;
        *)
            echo "Unsupported OS."
            exit 1
            ;;
        esac
    fi

    echo "Activating Homebrew for current session..."
    eval_brew_shellenv_now

    echo "Persisting Homebrew environment..."
    persist_brew_shellenv

    echo "Installing from Brewfile"
    install_from_brewfile

    brew doctor || true

    echo "Done. Open a new shell or run: eval \"\$($(brew --prefix)/bin/brew shellenv)\""
}

main "$@"
