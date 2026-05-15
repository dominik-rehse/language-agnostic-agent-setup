# language-agnostic-agent-setup

Baseline rules for AI coding agents.

Each rule in `rules/` is a single Markdown file with Cursor frontmatter. The installer renames it to `.mdc` for Cursor and strips the frontmatter for Claude Code, so there's one source of truth per rule.

## Install

### Claude Code

```text
/plugin marketplace add dominik-rehse/language-agnostic-agent-setup
/plugin install language-agnostic-agent-setup@language-agnostic-agent-setup
```

Then run `/language-agnostic-agent-setup:setup` — it runs `scripts/install.sh` in the current project.

### Cursor

Clone this repo, then run `scripts/install.sh` directly:

```bash
bash path/to/language-agnostic-agent-setup/scripts/install.sh
```

Pass `--claude` or `--cursor` to install only one target (default: both).
