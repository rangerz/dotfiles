#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
[Brew] Automatic uninstallation of Homebrew is not supported.
Please run the following command manually:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
EOF
