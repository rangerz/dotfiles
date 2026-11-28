#!/usr/bin/env bash
# agy status line modeled on agents/claude/ccstatusline.json: three powerline lines in the
# nord-aurora palette (model/context, quota/cost, git/dir). Payload fields follow
# https://antigravity.google/docs/cli/statusline and the official example (vcs.branch, vcs.dirty)
set -euo pipefail

input="$(cat)"
# \x1f, not tab: tab counts as whitespace for read, so empty fields would shift the rest
IFS=$'\x1f' read -r state model effort used mode quota cost cwd branch dirty <<<"$(jq -r '[
    (.agent_state // "idle"),
    (.model.display_name // "-" | sub(" \\([^)]*\\)$"; "")),
    (.model.effort // ""),
    ((.context_window.used_percentage // 0) | floor | tostring),
    (.cycle_mode // "default"),
    # Only buckets that report a fraction: one without it must not read as 100% left
    ([(.quota // {}) | to_entries[] | select(.value.disabled != true and .value.remaining_fraction != null)
        | "\(.key | sub("^gemini-"; ""))=\((.value.remaining_fraction * 100) | floor)=\((.value.reset_in_seconds // 0) / 3600 | floor)"]
        | join(" ")),
    (.cost.total_usd // "" | tostring),
    (.workspace.current_dir // .cwd // ""),
    (.vcs.branch // ""),
    (.vcs.dirty // "" | tostring)
] | join("\u001f")' <<<"$input" 2>/dev/null || true)"

E=$'\e'
# Powerline arrow U+E0B0 as UTF-8 bytes (needs a Nerd/Powerline font, as ccstatusline does)
ARROW=$'\xee\x82\xb0'
# nord-aurora in 256 colors (ccstatusline uses colorLevel 2)
RED=131 ORANGE=173 YELLOW=222 GREEN=144 PURPLE=139 LAVENDER=103 FROST=110 BLUE=67 GRAY=240 DARK=236 LIGHT=254
line="" prev=""
seg() { # <bg> <fg> <text>: one powerline segment; empty text adds nothing
    [[ -n "$3" ]] || return 0
    [[ -z "$prev" ]] || line+="${E}[38;5;${prev}m${E}[48;5;$1m$ARROW"
    line+="${E}[38;5;$2m${E}[48;5;$1m $3 "
    prev=$1
}
flush() { # end the current line with a closing arrow; print nothing for an empty line
    [[ -n "$prev" ]] || return 0
    printf '%s\n' "$line${E}[0m${E}[38;5;${prev}m$ARROW${E}[0m"
    line="" prev=""
}
level() { # <percent used> -> green / yellow / red
    if (($1 >= 80)); then echo "$RED"; elif (($1 >= 50)); then echo "$YELLOW"; else echo "$GREEN"; fi
}

# Line 1: agent state, model, effort, context, mode
case "$state" in
idle) seg "$GREEN" "$DARK" "● ready" ;;
working | tool_use) seg "$FROST" "$DARK" "⚙ ${state/_/ }" ;;
*) seg "$PURPLE" "$DARK" "◆ ${state:-idle}" ;;
esac
seg "$BLUE" "$LIGHT" "$model"
seg "$GRAY" "$LIGHT" "$effort"
seg "$(level "${used:-0}")" "$DARK" "ctx ${used:-0}%"
# default means the configured mode did not apply (e.g. auto on an account without it)
case "$mode" in
default) seg "$RED" "$LIGHT" "$mode" ;;
*) seg "$ORANGE" "$DARK" "$mode" ;;
esac
flush

# Line 2: quota buckets (remaining %, hours to reset) and session cost
for bucket in $quota; do
    IFS='=' read -r name left reset <<<"$bucket"
    text="$name $left%"
    ((reset > 0)) && text+=" ↻${reset}h"
    seg "$(level $((100 - left)))" "$DARK" "$text"
done
[[ -n "$cost" ]] && seg "$GREEN" "$DARK" "$(LC_NUMERIC=C printf '$%.2f' "$cost")"
flush

# Line 3: origin owner/repo, branch, changes, ahead/behind, directory
US=$'\x1f'
git_info() { # <dir> -> repo, branch, changes, ahead/behind joined by \x1f; nothing outside a repo
    git -C "$1" rev-parse --git-dir >/dev/null 2>&1 || return 0
    local repo branch changes ahead_behind
    repo="$(git -C "$1" remote get-url origin 2>/dev/null | sed -E 's#(\.git)?$##; s#.*[:/]([^/]+/[^/]+)$#\1#' || true)"
    branch="$(git -C "$1" branch --show-current 2>/dev/null || true)"
    changes="$(git -C "$1" diff --numstat HEAD 2>/dev/null | awk '{a += $1; d += $2} END {if (a + d) printf "+%d -%d", a, d}' || true)"
    ahead_behind="$(git -C "$1" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null |
        awk '{s = ""; if ($2) s = "↑" $2; if ($1) s = s (s ? " " : "") "↓" $1; print s}' || true)"
    printf '%s' "$repo$US$branch$US$changes$US$ahead_behind"
}
# Cache git output per directory for 5s, like ccstatusline's gitCacheTtlSeconds: agy refreshes up to every 300ms
info=""
if [[ -n "$cwd" ]]; then
    cache_dir="${TMPDIR:-/tmp}/agy-statusline-$UID"
    # No -p: the parent ($TMPDIR or /tmp) exists, and -m would not apply to parents anyway
    [[ -d "$cache_dir" ]] || mkdir -m 700 "$cache_dir" 2>/dev/null || true
    # On a shared /tmp another user could create this dir first and plant entries: use it only if it is ours
    if [[ -O "$cache_dir" ]]; then
        cache="$cache_dir/$(printf '%s' "$cwd" | cksum | cut -d' ' -f1)"
        now="$(date +%s)"
        ts=""
        [[ -f "$cache" ]] && IFS="$US" read -r ts info <"$cache"
        if [[ ! "$ts" =~ ^[0-9]+$ ]] || ((now - ts >= 5)); then
            info="$(git_info "$cwd")"
            # Write then rename, so a status line running in another agy session never reads half a file
            { tmp="$(mktemp "$cache_dir/.XXXXXX")" && printf '%s\n' "$now$US$info" >"$tmp" && mv "$tmp" "$cache"; } 2>/dev/null || true
        fi
    else
        info="$(git_info "$cwd")"
    fi
fi
IFS="$US" read -r repo git_branch changes ahead_behind <<<"$info"
[[ -n "$branch" ]] || branch="$git_branch"
[[ -z "$info" || -n "$changes" || "$dirty" != true ]] || changes="●"
seg "$PURPLE" "$DARK" "$repo"
seg "$LAVENDER" "$LIGHT" "$branch"
seg "$YELLOW" "$DARK" "$changes"
seg "$FROST" "$DARK" "$ahead_behind"
if [[ -n "$cwd" ]]; then
    # Prefix strip, not ${cwd/#$HOME/\~}: bash 3.2 (macOS /bin/bash) keeps the backslash in that replacement
    [[ "$cwd" == "$HOME" || "$cwd" == "$HOME"/* ]] && cwd="~${cwd#"$HOME"}"
    seg "$DARK" "$LIGHT" "$cwd"
fi
flush
