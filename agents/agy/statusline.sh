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
if [[ -n "$cwd" ]] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    # shortcut: git runs on every refresh (agy throttles to 300ms); add a cache if big repos lag
    repo="$(git -C "$cwd" remote get-url origin 2>/dev/null | sed -E 's#(\.git)?$##; s#.*[:/]([^/]+/[^/]+)$#\1#' || true)"
    [[ -n "$branch" ]] || branch="$(git -C "$cwd" branch --show-current 2>/dev/null || true)"
    changes="$(git -C "$cwd" diff --numstat HEAD 2>/dev/null | awk '{a += $1; d += $2} END {if (a + d) printf "+%d -%d", a, d}' || true)"
    [[ -n "$changes" || "$dirty" != true ]] || changes="●"
    ahead_behind="$(git -C "$cwd" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null |
        awk '{s = ""; if ($2) s = "↑" $2; if ($1) s = s (s ? " " : "") "↓" $1; print s}' || true)"
    seg "$PURPLE" "$DARK" "$repo"
    seg "$LAVENDER" "$LIGHT" "$branch"
    seg "$YELLOW" "$DARK" "$changes"
    seg "$FROST" "$DARK" "$ahead_behind"
fi
if [[ -n "$cwd" ]]; then
    # Prefix strip, not ${cwd/#$HOME/\~}: bash 3.2 (macOS /bin/bash) keeps the backslash in that replacement
    [[ "$cwd" == "$HOME" || "$cwd" == "$HOME"/* ]] && cwd="~${cwd#"$HOME"}"
    seg "$DARK" "$LIGHT" "$cwd"
fi
flush
