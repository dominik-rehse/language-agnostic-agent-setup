---
description: Vendor language-agnostic-agent-setup into the current project. Copies rules to .claude/rules/*.md (and optionally .cursor/rules/*.mdc with --cursor or --both). Invoke with /language-agnostic-agent-setup:setup.
argument-hint: "[--cursor | --both]"
disable-model-invocation: true
---

# /language-agnostic-agent-setup:setup — Vendor rules into the current project

Run once per project. This is the only install path — there is no SessionStart auto-mirror, so the rules only land in the project after this command runs and they're tracked in source control like any other file.

Safe to re-run; existing files are not overwritten.

## Task

Run the installer that ships with the plugin:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" $ARGUMENTS
```

Pass `--claude`, `--cursor`, or `--both` to choose which targets get installed. The default (no flag) installs both.

After the script finishes, confirm with:

> language-agnostic-agent-setup installed.
