#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TARGET="$HOME/.config/mise/config.toml"

# brew's bin is not on PATH yet when called from the top-level install.sh
if ! command -v mise >/dev/null 2>&1; then
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
        if [[ -x "$prefix/bin/brew" ]]; then
            eval "$("$prefix/bin/brew" shellenv)"
            break
        fi
    done
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "[mise] mise is not installed or not in PATH."
    exit 1
fi

# Back up an existing real file before linking
if [[ -f "$TARGET" && ! -L "$TARGET" ]]; then
    mv "$TARGET" "$TARGET.bak"
    echo "[mise] Backed up existing config to $TARGET.bak"
fi
mkdir -p "$(dirname "$TARGET")"
ln -sfn "$CUR_DIR/config.toml" "$TARGET"

mise install

echo "[mise] Installation completed."
