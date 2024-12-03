#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"

if ! type git >/dev/null 2>&1; then
    echo "Git is not installed."
    exit
fi

if ! git config --get-all include.path | grep -q "$GIT_CONFIG"; then
    echo "No vim config found in ~/.gitconfig. No changes made."
    exit
fi

git config --global --unset include.path "$GIT_CONFIG"

echo "[Git] Uninstallation completed."