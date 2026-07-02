<!--
  TEMPORARY WORKAROUND — hopefully removable.
  The AskUserQuestion tool has a hardcoded ~60s timeout after which Claude Code
  proceeds without the user's answer. There is currently no setting, env var, or
  plugin hook to disable it. This rule steers clarifying questions toward plain
  text (which waits indefinitely) instead. Delete this file once Claude Code adds
  a configurable/disable-able AskUserQuestion timeout.
  Tracking: run /feedback in Claude Code to request the setting.
-->

# Interactive questions

- When you need the user's input on a blocking decision, ask as plain text at the end of your response and stop, rather than using the structured `AskUserQuestion` tool. A plain-text question waits for the user indefinitely; the structured tool times out after ~60s and proceeds without an answer.
- Never proceed on an assumed answer to a genuinely blocking question just because a prompt timed out. If input is essential, wait for it.
