#!/usr/bin/env bash
# WSL-only packages from wsl/install.sh are common tools (git, curl, ...), so do not remove them automatically.
set -euo pipefail

# WSL check (matches wsl/install.sh)
if ! grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
    exit 0
fi

cat <<'MSG'
[WSL] Automatic removal of the WSL apt packages is not supported.
To remove them, check wsl/install.sh for the list and run, for example:

    sudo apt-get remove wslu fonts-noto-cjk

To remove Google Chrome (installed by wsl/install-chrome.sh), run:

    sudo apt-get purge google-chrome-stable
MSG
