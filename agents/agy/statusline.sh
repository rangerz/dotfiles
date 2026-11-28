#!/usr/bin/env bash
# agy status line: the same items as the Claude ccstatusline (model, git branch, context used, quota, directory),
# plus the agent mode, since agy silently falls back to default when a mode is unavailable
set -euo pipefail

input="$(cat)"
IFS=$'\x1f' read -r model mode cwd used quota <<<"$(jq -r '[
    (.model.display_name // "-"),
    (.cycle_mode // "default"),
    (.workspace.current_dir // .cwd // ""),
    ((.context_window.used_percentage // 0) | floor | tostring),
    # Only buckets that report a fraction: one without it must not read as 100% left
    ([(.quota // {}) | to_entries[] | select(.value.disabled != true and .value.remaining_fraction != null)
        | "\(.key | sub("^gemini-"; "")) \((.value.remaining_fraction * 100) | floor)%"] | join(" "))
] | join("\u001f")' <<<"$input")"

# agy reports only the VCS type, not the branch
branch=""
[[ -n "$cwd" ]] && branch="$(git -C "$cwd" branch --show-current 2>/dev/null || true)"

dim=$'\e[2m' reset=$'\e[0m'
sep=" ${dim}|${reset} "
line="$model${sep}$mode"
[[ -n "$branch" ]] && line+="${sep}$branch"
line+="${sep}ctx ${used}%"
[[ -n "$quota" ]] && line+="${sep}$quota"
if [[ -n "$cwd" ]]; then
    # Prefix strip, not ${cwd/#$HOME/\~}: bash 3.2 (macOS /bin/bash) keeps the backslash in that replacement
    [[ "$cwd" == "$HOME" || "$cwd" == "$HOME"/* ]] && cwd="~${cwd#"$HOME"}"
    line+="${sep}$cwd"
fi
printf '%s\n' "$line"
