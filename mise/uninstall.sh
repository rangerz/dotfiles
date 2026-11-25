#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TARGET="$HOME/.config/mise/config.toml"

# Undo install.sh's link only, so it does not dangle once the repo is removed
if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$CUR_DIR/config.toml" ]]; then
    rm "$TARGET"
    # -L too: the backup may be a link, possibly dangling
    if [[ -f "$TARGET.bak" || -L "$TARGET.bak" ]]; then
        mv "$TARGET.bak" "$TARGET"
        echo "[mise] Restored previous config from $TARGET.bak"
    else
        # No earlier config: keep a copy so installed tools stay active
        cp "$CUR_DIR/config.toml" "$TARGET"
        echo "[mise] Replaced symlink with a copy at $TARGET"
    fi
fi

cat <<'EOF'

# Uninstall mise installed via Homebrew
brew remove mise

# To completely clean up mise, you may run the following commands manually:
rm -rf ~/.local/share/mise
rm -rf ~/.cache/mise
rm -rf ~/.config/mise

EOF
