#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SSH_CONFIG="$HOME/.ssh/config"
SSH_MUX_DIR="$HOME/.ssh/mux"
INCLUDE_CONFIG="Include $CUR_DIR/config"
SSH_KEYGEN="$CUR_DIR/ssh-keygen.sh"

# A fresh machine may have no ~/.ssh; keygen would create it, but it is skipped without a TTY
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -m 700 "$HOME/.ssh"
    echo "Created directory (700): $HOME/.ssh"
fi

# Generate the ed25519 key (also used to sign git commits)
"$SSH_KEYGEN"

# Ensure the ~/.ssh/config file exists
if [ ! -f "$SSH_CONFIG" ]; then
    touch "$SSH_CONFIG"
    echo "Created $SSH_CONFIG"
fi

# Check if the configuration already exists
if ! grep -qxF "$INCLUDE_CONFIG" "$SSH_CONFIG"; then
    echo "$INCLUDE_CONFIG" >>"$SSH_CONFIG"
    echo "SSH config successfully updated into $SSH_CONFIG"
else
    echo "SSH config already exists in $SSH_CONFIG. No changes made."
fi

# Create necessary directories
if [ ! -d "$SSH_MUX_DIR" ]; then
    mkdir -p "$SSH_MUX_DIR"
    chmod 700 "$SSH_MUX_DIR"
    echo "Created directory (700): $SSH_MUX_DIR"
fi

# git/configs/sign.ini signs every commit with this key, so without it every commit fails
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo "[SSH] WARNING: $HOME/.ssh/id_ed25519.pub is missing, so git commits will fail to sign." >&2
    echo "      Run $SSH_KEYGEN from an interactive shell, or commit with: git -c commit.gpgSign=false commit" >&2
fi

echo "[SSH] Installation completed."
