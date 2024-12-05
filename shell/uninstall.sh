#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SHELL_PROFILE="$CUR_DIR/profile"
SOURCE_PROFILE="source $SHELL_PROFILE"

case "$SHELL" in
  */zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  */bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  */fish)
    SHELL_RC="$HOME/.config/fish/config.fish"
    ;;
  *)
    echo "Unknown or unsupported SHELL environment: $SHELL"
    exit
    ;;
esac

# Remove the configuration
if grep -q "$SOURCE_PROFILE" "$SHELL_RC"; then
    grep -vF "$SOURCE_PROFILE" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "Shell config successfully removed from $SHELL_RC"
else
    echo "No vim config found in $SHELL_RC. No changes made."
    exit
fi

echo "[Shell] Uninstallation completed."