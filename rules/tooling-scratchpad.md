# Tooling scratchpad

When you discover or repeatedly reach for a project-specific tool — a CLI command or flag, an MCP server/tool, a skill, or a similar invocation — record it once so it isn't rediscovered from scratch each session.

- Prefer a natural home first. If the tool belongs to a workflow that already has one, document it there: a runbook for operational commands, the relevant file under `docs/` for its topic, or `CLAUDE.md` for a command central to building/testing/running the project.
- Only when no such home fits, append it to `docs/tooling-scratchpad.md` (create it if absent) as a catch-all. Treat this as a fallback, not the default.
- For each entry, record the exact invocation and one line on what it's for and when to use it. Keep it DRY — don't duplicate anything already documented; link to the natural home instead of copying.
- Periodically promote scratchpad entries to their natural home once one becomes clear, and prune entries that are stale or no longer used.
