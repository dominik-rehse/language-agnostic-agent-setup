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

## Skills

The plugin ships slash commands that are not vendored into projects — they run from the plugin itself:

- `/language-agnostic-agent-setup:setup` — vendor the rules into the current project (see [Install](#install)).
- `/language-agnostic-agent-setup:code-simplifier` — review the whole codebase and apply clarity and consistency simplifications while preserving behaviour. Pass a path to scope the pass to a subtree. Best run on a capable model, since it reasons across the entire repository.

## Re-running after a plugin update

The default install path is write-only-if-absent: it never clobbers a file you already have. After a plugin update, two extra modes pick up upstream changes:

- `--check` — read-only diff. Prints `ok` / `miss` / `drift` per file and exits 0 iff every file is byte-identical to upstream. Wire into CI to catch silent drift.
- `--force` — overwrite every file, even if it exists. Destructive against local edits. Run `--check` first.

```bash
bash path/to/install.sh --check         # what would change?
bash path/to/install.sh --force         # pick up upstream
```

The two modes are mutually exclusive. Target flags (`--claude` / `--cursor` / `--both`) work with all three modes.
