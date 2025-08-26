#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TOPGRADE_TOML="$CUR_DIR/topgrade.toml"
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/topgrade.d"
CONF_TOML="$CONF_DIR/dotfiles.toml"

if [ ! -f "$CONF_TOML" ]; then
    mkdir -p "$CONF_DIR"
    cp "$TOPGRADE_TOML" "$CONF_TOML"
    echo "[topgrade] Config file moved to $CONF_TOML"
else
    echo "[topgrade] Config file already exists at $CONF_TOML. No changes made."
fi

echo "[topgrade] Installation completed."
