#!/usr/bin/env bash
set -euo pipefail

REASON="Review the answer you just gave. If distinct, useful follow-up actions naturally remain, append a short section titled exactly \`Next steps:\` (keep this English heading even when the conversation is in another language) with three numbered, ready-to-send prompts by default. Include fewer only when fewer than three genuinely useful, distinct options remain. Make each option specific and easy to select by replying only with its number; the conversation should make that choice unambiguous. Do not repeat or revise the answer. If no meaningful follow-up exists, finish without adding anything."

if jq -e '
    if .stop_hook_active or ((.last_assistant_message // "") | type != "string" or length == 0 or contains("Next steps:")) then
        false
    else
        true
    end
' >/dev/null; then
    jq -cn --arg reason "$REASON" '{decision: "block", reason: $reason}'
fi
