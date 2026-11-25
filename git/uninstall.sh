#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"

if ! command -v git >/dev/null 2>&1; then
    echo "[Error] git is not installed or not in PATH."
    exit 1
fi

# Whole-line fixed-string match on the global file only: install.sh writes there, and the path's "." is a regex wildcard
if ! git config --global --get-all include.path | grep -qxF "$GIT_CONFIG"; then
    echo "No git config found in ~/.gitconfig. No changes made."
else
    # --fixed-value: match the path literally; --unset-all also clears duplicates
    git config --global --fixed-value --unset-all include.path "$GIT_CONFIG"
fi

echo "[Git] Uninstallation completed."
