#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TOPGRADE_TOML="$CUR_DIR/topgrade.toml"
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/topgrade.d"
CONF_TOML="$CONF_DIR/dotfiles.toml"

# Back up a link to somewhere else, or a real file that differs from ours;
# keep the backup outside topgrade.d so topgrade does not load it
needs_backup() {
    if [[ -L "$CONF_TOML" ]]; then
        [[ "$(readlink "$CONF_TOML")" != "$TOPGRADE_TOML" ]]
    else
        [[ -f "$CONF_TOML" ]] && ! cmp -s "$CONF_TOML" "$TOPGRADE_TOML"
    fi
}
if needs_backup; then
    mv "$CONF_TOML" "$CONF_DIR/../topgrade-dotfiles.toml.bak"
    echo "[topgrade] Backed up existing config to $CONF_DIR/../topgrade-dotfiles.toml.bak"
fi

# Link (not copy) so later edits in the repo take effect
mkdir -p "$CONF_DIR"
ln -sfn "$TOPGRADE_TOML" "$CONF_TOML"
echo "[topgrade] Linked $CONF_TOML -> $TOPGRADE_TOML"

echo "[topgrade] Installation completed."
