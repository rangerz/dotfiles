#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
GIT_CONFIG="$CUR_DIR/gitconfig"

if ! type git >/dev/null 2>&1; then
    echo "Git is not installed."
    exit
fi

if git config --get-all include.path | grep -q "$GIT_CONFIG"; then
    echo "Git config already exists in ~/.gitconfig. No changes made."
    exit
fi

# Update git_commit_template, gitignore, and gitattributes path
git config --file "$GIT_CONFIG" core.excludesfile "$CUR_DIR/gitignore"
git config --file "$GIT_CONFIG" core.attributesfile "$CUR_DIR/attributesfile"
git config --file "$GIT_CONFIG" commit.template "$CUR_DIR/git_commit_template"

# MacOSX only for detla and diffmerge
if [[ "$OSTYPE" == "darwin"* ]]; then
    git config --file "$GIT_CONFIG" --unset-all include.path

    # DiffMerge: https://sourcegear.com/diffmerge/webhelp/sec__git.html
    # Delta: https://github.com/dandavison/
    git config --file "$GIT_CONFIG" --add include.path "$CUR_DIR/gitconfig_diffmerge_mac"
    git config --file "$GIT_CONFIG" --add include.path "$CUR_DIR/gitconfig_delta_mac"
fi

git config --global --add include.path "$GIT_CONFIG"

echo "[Git] Installation completed."
