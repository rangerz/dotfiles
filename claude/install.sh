#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"

# Back up an existing real file before linking
# 連結前先備份既有的實體檔案
if [[ -f "$TARGET" && ! -L "$TARGET" ]]; then
    mv "$TARGET" "$TARGET.bak"
    echo "[claude] Backed up existing ccstatusline config to $TARGET.bak"
fi
mkdir -p "$(dirname "$TARGET")"
ln -sfn "$CUR_DIR/ccstatusline.json" "$TARGET"

# brew's bin is not on PATH yet when called from the top-level install.sh
# 從頂層 install.sh 呼叫時，brew 的 bin 還不在 PATH 上
if ! command -v claude >/dev/null 2>&1; then
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
        if [[ -x "$prefix/bin/brew" ]]; then
            eval "$("$prefix/bin/brew" shellenv)"
            break
        fi
    done
fi

if ! command -v claude >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "[claude] claude or jq not found, skipping plugins."
else
    # Match marketplaces by repo (case-insensitive): their local name comes from the repo, not from us
    # 以 repo 比對 marketplace(不分大小寫):本地名稱由 repo 決定，不是我們指定的
    installed_markets="$(claude plugin marketplace list --json | jq -r '.[].repo // empty' | tr '[:upper:]' '[:lower:]' || true)"
    installed_plugins="$(claude plugin list --json | jq -r '.[].id' || true)"

    # `|| [[ -n "$kind" ]]` keeps a last line that has no trailing newline
    # 保留結尾沒有換行字元的最後一行
    while read -r kind value || [[ -n "$kind" ]]; do
        case "$kind" in
        marketplace)
            if grep -qxF "$(tr '[:upper:]' '[:lower:]' <<<"$value")" <<<"$installed_markets"; then
                echo "[claude] Marketplace $value already added."
            else
                claude plugin marketplace add "$value" || echo "[claude] Failed to add marketplace $value, continuing."
            fi
            ;;
        plugin)
            if grep -qxF "$value" <<<"$installed_plugins"; then
                echo "[claude] Plugin $value already installed."
            else
                claude plugin install "$value" || echo "[claude] Failed to install plugin $value, continuing."
            fi
            ;;
        "" | \#*) ;;
        *) echo "[claude] Unknown entry in plugins.txt: $kind $value" ;;
        esac
    done <"$CUR_DIR/plugins.txt"
fi

echo "[claude] Installation completed."
