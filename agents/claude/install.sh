#!/usr/bin/env bash
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Global instructions shared with Codex and agy
AGENTS_MD="$(cd "$CUR_DIR/.." && pwd)/global.md"

AGENT=claude
# shellcheck source=agents/link.sh
source "$CUR_DIR/../link.sh"

link "$CUR_DIR/ccstatusline.json" "${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"
# Drop our old link (agents/claude/CLAUDE.md, now gone) so it is not backed up as a dangling .bak
if [[ -L "$HOME/.claude/CLAUDE.md" && "$(readlink "$HOME/.claude/CLAUDE.md")" == "$CUR_DIR/CLAUDE.md" ]]; then
    rm "$HOME/.claude/CLAUDE.md"
fi
link "$AGENTS_MD" "$HOME/.claude/CLAUDE.md"

# brew's bin is not on PATH yet when called from the top-level install.sh; claude may come from elsewhere, so check jq too
if ! command -v claude >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
        if [[ -x "$prefix/bin/brew" ]]; then
            eval "$("$prefix/bin/brew" shellenv)"
            break
        fi
    done
fi

# Merge tracked settings into the live file (repo wins); not a symlink because Claude rewrites this file
SETTINGS="$HOME/.claude/settings.json"
if ! command -v jq >/dev/null 2>&1; then
    echo "[claude] jq not found, skipping settings merge."
else
    [[ -f "$SETTINGS" ]] || echo '{}' >"$SETTINGS"
    # Same dir keeps mv atomic; mktemp creates 0600, so restore 0644
    tmp="$(mktemp "$SETTINGS.XXXXXX")"
    if jq -s '.[0] * .[1]' "$SETTINGS" "$CUR_DIR/settings.json" >"$tmp"; then
        chmod 644 "$tmp"
        mv "$tmp" "$SETTINGS"
        echo "[claude] Merged settings into $SETTINGS"
    else
        rm -f "$tmp"
        echo "[claude] Could not merge settings (see jq error above), skipping."
    fi
fi

if ! command -v claude >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "[claude] claude or jq not found, skipping plugins."
else
    # Match marketplaces by repo (case-insensitive): their local name comes from the repo, not from us
    installed_markets="$(claude plugin marketplace list --json </dev/null | jq -r '.[].repo // empty' | tr '[:upper:]' '[:lower:]' || true)"
    installed_plugins="$(claude plugin list --json </dev/null | jq -r '.[].id' || true)"

    # `|| [[ -n "$kind" ]]` keeps a last line that has no trailing newline; </dev/null keeps claude off the loop's stdin
    while read -r kind value || [[ -n "$kind" ]]; do
        case "$kind" in
        marketplace)
            if grep -qxF "$(tr '[:upper:]' '[:lower:]' <<<"$value")" <<<"$installed_markets"; then
                echo "[claude] Marketplace $value already added."
            else
                claude plugin marketplace add "$value" </dev/null || echo "[claude] Failed to add marketplace $value, continuing."
            fi
            ;;
        plugin)
            if grep -qxF "$value" <<<"$installed_plugins"; then
                echo "[claude] Plugin $value already installed."
            else
                claude plugin install "$value" </dev/null || echo "[claude] Failed to install plugin $value, continuing."
            fi
            ;;
        "" | \#*) ;;
        *) echo "[claude] Unknown entry in plugins.txt: $kind $value" ;;
        esac
    done <"$CUR_DIR/plugins.txt"

    # `claude mcp get` exits non-zero when the server is not configured; </dev/null keeps claude off the loop's stdin
    # read -ra splits on whitespace without glob expansion
    while read -ra parts || [[ ${#parts[@]} -gt 0 ]]; do
        name="${parts[0]:-}"
        case "$name" in
        "" | \#*) continue ;;
        esac
        if claude mcp get "$name" >/dev/null 2>&1 </dev/null; then
            echo "[claude] MCP server $name already added."
        elif [[ "${parts[1]:-}" == http*://* ]]; then
            claude mcp add --scope user --transport http "$name" "${parts[1]}" </dev/null || echo "[claude] Failed to add MCP server $name, continuing."
        else
            # shortcut: args cannot contain spaces (no quoting support); switch to `claude mcp add-json` if one does
            claude mcp add --scope user "$name" -- "${parts[@]:1}" </dev/null || echo "[claude] Failed to add MCP server $name, continuing."
        fi
    done <"$CUR_DIR/../mcps.txt"
fi

echo "[claude] Installation completed."
