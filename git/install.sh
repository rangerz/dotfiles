#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"

if ! command -v git >/dev/null 2>&1; then
    echo "[Error] git is not installed or not in PATH."
    exit 1
fi

if git config --get-all include.path | grep -q "$GIT_CONFIG"; then
    echo "Git config already exists in ~/.gitconfig. No changes made."
else
    git config --global --add include.path "$GIT_CONFIG"
fi

# Enable this repo's pre-commit hook (shfmt + shellcheck)
git -C "$CUR_DIR/.." config core.hooksPath .githooks

echo "[Git] Installation completed."
