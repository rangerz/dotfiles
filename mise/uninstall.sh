#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'

# Uninstall mise installed via Homebrew
brew remove mise

# To completely clean up mise, you may run the following commands manually:
rm -rf ~/.local/share/mise
rm -rf ~/.cache/mise
rm -rf ~/.config/mise

EOF
