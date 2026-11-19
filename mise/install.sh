#!/usr/bin/env bash
set -euo pipefail

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

mise use -g \
    node@lts \
    python@3 \
    ruff@latest \
    "rust[targets=wasm32-wasip1]@latest" \
    npm:ccstatusline \
    npm:@axe-core/cli \
    npm:@shopify/cli

echo "[mise] Installation completed."
