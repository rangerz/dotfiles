#!/usr/bin/env python3
"""Ask Codex to append numbered follow-up prompts after a completed turn."""

import json
import sys


def main() -> None:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        return

    message = event.get("last_assistant_message")
    if event.get("stop_hook_active") or not isinstance(message, str) or not message.strip():
        return

    if "接下來可以：" in message or "Next steps:" in message:
        return

    reason = (
        "Review the answer you just gave. If distinct, useful follow-up actions naturally "
        "remain, append a short section titled `接下來可以：` (or `Next steps:` when the "
        "conversation is in English) with three numbered, ready-to-send prompts by default. "
        "Include fewer only when fewer than three genuinely useful, distinct options remain. "
        "Make each option specific and easy to select by replying only with its number; "
        "the conversation should make that choice unambiguous. Do not repeat or revise "
        "the answer. If no meaningful follow-up exists, finish without adding anything."
    )
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))


if __name__ == "__main__":
    main()
