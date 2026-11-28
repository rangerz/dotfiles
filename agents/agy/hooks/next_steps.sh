#!/usr/bin/env bash
# agy Stop hook: adapt agy's hook contract to the Codex next steps hook, which holds the shared prompt
set -euo pipefail

CODEX_HOOK="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../codex/hooks" && pwd)/next_steps.sh"

input="$(cat)"
# agy does not pass the last answer; read it from the transcript (no transcript means no answer, so no block)
transcript="$(jq -r '.transcriptPath // empty' <<<"$input")"
last=""
if [[ -f "$transcript" ]]; then
    last="$(jq -rs 'map(select(.type == "PLANNER_RESPONSE")) | last | .content // ""' "$transcript")"
fi

# Only a normal turn end asks for next steps, and only once per turn (continuationActive)
out="$(jq -c --arg last "$last" '{
    stop_hook_active: ((.continuationActive // false) or ((.terminationReason // "NO_TOOL_CALL") != "NO_TOOL_CALL")),
    last_assistant_message: $last
}' <<<"$input" | bash "$CODEX_HOOK")"

if [[ -n "$out" ]]; then
    jq -c '.decision = "continue"' <<<"$out"
else
    echo '{}'
fi
