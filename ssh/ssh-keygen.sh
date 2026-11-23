#!/usr/bin/env zsh
# shellcheck disable=SC1071 # zsh script, not supported by shellcheck
set -euo pipefail

# Keys are generated WITH a passphrase (ssh-keygen prompts for it); never use -N ""
# because the ed25519 key also signs git commits.
# 私鑰一律設 passphrase(由 ssh-keygen 互動詢問),不可用 -N "",
# 因為 ed25519 同時用來簽 git commit。
if [ ! -t 0 ]; then
    echo "[SSH] No terminal for the passphrase prompt; skipping key generation." >&2
    echo "      Run ssh/ssh-keygen.sh from an interactive shell later." >&2
    exit 0
fi

# Check if the ed25519 key already exists
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -a 100 -f "$HOME/.ssh/id_ed25519"
else
    echo "ed25519 SSH key already exists, skipping..."
fi
