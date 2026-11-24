#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TOPGRADE_TOML="$CUR_DIR/topgrade.toml"
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/topgrade.d"
CONF_TOML="$CONF_DIR/dotfiles.toml"
BACKUP="$CONF_DIR/../topgrade-dotfiles.toml.bak"

# Remove only what install.sh put there: its link, or an identical copy left by older versions that copied
is_ours() {
    if [[ -L "$CONF_TOML" ]]; then
        [[ "$(readlink "$CONF_TOML")" == "$TOPGRADE_TOML" ]]
    else
        [[ -f "$CONF_TOML" ]] && cmp -s "$CONF_TOML" "$TOPGRADE_TOML"
    fi
}
if ! is_ours; then
    echo "[topgrade] No dotfiles config at $CONF_TOML. Nothing to uninstall."
    exit 0
fi

rm "$CONF_TOML"
echo "[topgrade] Removed $CONF_TOML"

# -L too: the backup may be a link, possibly dangling
if [[ -f "$BACKUP" || -L "$BACKUP" ]]; then
    mv "$BACKUP" "$CONF_TOML"
    echo "[topgrade] Restored previous config from $BACKUP"
fi

if [ -d "$CONF_DIR" ] && [ -z "$(ls -A "$CONF_DIR")" ]; then
    rmdir "$CONF_DIR"
    echo "[topgrade] Removed empty directory $CONF_DIR"
fi

echo "[topgrade] Uninstallation completed."
