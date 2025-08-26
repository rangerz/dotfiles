#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/topgrade.d"
CONF_TOML="$CONF_DIR/dotfiles.toml"

if [ ! -e "$CONF_TOML" ]; then
    echo "[topgrade] No config found at $CONF_TOML. Nothing to uninstall."
    exit 0
fi

rm -f "$CONF_TOML"
echo "[topgrade] Removed $CONF_TOML"

if [ -d "$CONF_DIR" ] && [ -z "$(ls -A "$CONF_DIR")" ]; then
    rmdir "$CONF_DIR"
    echo "[topgrade] Removed empty directory $CONF_DIR"
fi

echo "[topgrade] Uninstallation completed."
