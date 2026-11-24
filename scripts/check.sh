#!/usr/bin/env bash
# Run every repo check: lint all shell scripts, then each module's installer self-check
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$CUR_DIR/.."

for tool in shfmt shellcheck jq zsh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[check] $tool is not installed." >&2
        exit 1
    fi
done

# Plain assignment so a shfmt error stops the script (set -e misses failures inside a pipe's left side)
list=$(shfmt -f .)
echo "[check] shellcheck"
xargs shellcheck <<<"$list"
echo "[check] shfmt"
shfmt -d .

for test in */test-install.sh; do
    echo "[check] $test"
    "./$test"
done

echo "[check] All checks passed."
