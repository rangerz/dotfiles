---
name: next-steps
description: After preparing a response, decide whether concrete follow-up prompts would help the user continue. When useful, append three distinct, ready-to-send options by default; include fewer only when fewer useful options exist. Do not add suggestions when they would be generic, redundant, or distracting.
---

# Next Steps

When the turn naturally leaves distinct, useful follow-ups, append a section titled exactly `Next steps:` with three concise, numbered prompts by default. Keep this English heading even when the conversation is in another language; the Stop hook detects it by this exact text. Include fewer only when fewer than three genuinely useful, distinct options remain; omit the section when none remain. Keep choices specific, grounded in the conversation, and easy to select by replying with a number. Skip trivial or complete answers; never add filler options or imply an action is approved or done.
