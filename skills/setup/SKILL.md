---
description: Vendor language-agnostic-agent-setup into the current project. Copies rules to .claude/rules/*.md. Invoke with /language-agnostic-agent-setup:setup. Supports --check (read-only drift detection) and --force (overwrite existing files) for re-runs after upstream updates.
argument-hint: "[--check | --force]"
disable-model-invocation: true
---

# /language-agnostic-agent-setup:setup — Vendor rules into the current project

Run once per project to install. Re-run with `--check` to detect upstream updates, or with `--force` to pull them in. The rules land in source control like any other file.

By default the installer is write-only-if-absent: re-running after a plugin update is a no-op on every file that already exists. Use the modes below to deal with updates.

## Task

Run the installer that ships with the plugin:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" $ARGUMENTS
```

Mode flags (mutually exclusive):

- _default_ — write only files that are absent; never clobber existing.
- `--check` — read-only diff. Reports `ok` / `miss` / `drift` per file. Exits 0 iff every file is byte-identical to upstream. Use from CI as a "rules in sync" guard.
- `--force` — overwrite every file, even if it already exists. Destructive against local customisations. Run `--check` first to see what would change.

After the script finishes, confirm with:

> language-agnostic-agent-setup installed.
